--@ commons pid lookuptable normalizebearing getvectorangle sign
-- Plane-like module (Yaw, Pitch, Throttle)
PlaneLikeControl = {}

PlaneLike_AltitudePID = PID.new(AirplanePIDConfig.Altitude, -10, 10)

PlaneLike_DesiredAltitude = 0
PlaneLike_DesiredHeading = nil
PlaneLike_DesiredPosition = nil

PlaneLike_MaxPitch = LookupTable.new(MaxPitch[1][1], math.max(PlaneLike_MaxAltitude, MaxPitch[#MaxPitch][1]), MaxPitch[1][2], MaxPitch[#MaxPitch][2], 100, MaxPitch)

PlaneLike = {}

function PlaneLike.SetAltitude(Alt)
   PlaneLike_DesiredAltitude = Alt
end

function PlaneLike.SetHeading(Heading)
   PlaneLike_DesiredHeading = Heading % 360
end

function PlaneLike.ResetHeading()
   PlaneLike_DesiredHeading = nil
end

function PlaneLike.SetPosition(Pos)
   -- Make copy to be safe
   PlaneLike_DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function PlaneLike.ResetPosition()
   PlaneLike_DesiredPosition = nil
end

function PlaneLike.Update(_)
   local Altitude = C:Altitude()

   -- Determine target vector
   local TargetVector,DesiredHeading
   if PlaneLike_DesiredPosition then
      TargetVector = (PlaneLike_DesiredPosition - C:CoM()).normalized
      DesiredHeading = GetVectorAngle(TargetVector)
   else
      DesiredHeading = PlaneLike_DesiredHeading
      -- Be sure to flip sign and divide by PID scale
      local PitchForAltitude = PlaneLike_MaxPitch:Lookup(Altitude) * PlaneLike_AltitudePID:Control(PlaneLike_DesiredAltitude - Altitude) / -10
      TargetVector = Quaternion.Euler(PitchForAltitude, DesiredHeading or 0, 0) * Vector3.forward
   end

   -- Roll turn logic
   local DesiredRoll = 0
   if AngleBeforeRoll and DesiredHeading then
      local Bearing = NormalizeBearing(DesiredHeading - GetVectorAngle(C:ForwardVector()))
      local AbsBearing = math.abs(Bearing)
      if AbsBearing > AngleBeforeRoll and Altitude >= MinAltitudeForRoll then
         local RollAngle = RollAngleGain and math.min(MaxRollAngle, (AbsBearing - AngleBeforeRoll) * RollAngleGain) or MaxRollAngle
         DesiredRoll = -Sign(Bearing) * RollAngle
      end
   end

   -- Convert TargetVector to local coordinates
   TargetVector = C:ToLocal() * TargetVector

   -- Determine angles
   local z = TargetVector.z
   local Yaw = math.deg(math.atan2(TargetVector.x, z))
   --# Pitch must be [-90, 90], so use normal atan
   --# Lua is apparently fine with dividing by zero.
   --# Divide by 0 -> +/- infinity -> atan -> +/- 90. Perfect!
   local Pitch = math.deg(math.atan(TargetVector.y / z))

   -- Apply to underlying controls
   PlaneLikeControl.AdjustHeading(Yaw)
   PlaneLikeControl.SetPitch(C:Pitch() + Pitch)
   PlaneLikeControl.SetRoll(DesiredRoll)
   --# Throttle is expected to be passed through directly.
end
