--@ commons propulsionapi requestcontrol pid lookuptable normalizebearing getvectorangle sign clamp
-- Airplane module (Yaw, Pitch, Throttle)
Airplane_AltitudePID = PID.new(AirplanePIDConfig.Altitude, -10, 10)
Airplane_YawPID = PID.new(AirplanePIDConfig.Yaw, -1, 1)
Airplane_PitchPID = PID.new(AirplanePIDConfig.Pitch, -1, 1)
Airplane_RollPID = PID.new(AirplanePIDConfig.Roll, -1, 1)

Airplane_DesiredAltitude = 0
Airplane_DesiredHeading = nil
Airplane_DesiredPosition = nil
Airplane_DesiredThrottle = nil
Airplane_CurrentThrottle = 0

Airplane_LastSpinnerCount = 0
Airplane_SpinnerInfos = {}

Airplane_UsesSpinners = (SpinnerFractions.Yaw > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0 or SpinnerFractions.Throttle > 0)

Airplane_MaxPitch = LookupTable.new(MaxPitch[1][1], math.max(Airplane_MaxAltitude, MaxPitch[#MaxPitch][1]), MaxPitch[1][2], MaxPitch[#MaxPitch][2], 100, MaxPitch)

Airplane_Active = false

Airplane = {}

function Airplane.SetAltitude(Alt)
   Airplane_DesiredAltitude = Alt
end

function Airplane.SetHeading(Heading)
   Airplane_DesiredHeading = Heading % 360
end

function Airplane.ResetHeading()
   Airplane_DesiredHeading = nil
end

function Airplane.SetPosition(Pos)
   -- Make copy to be safe
   Airplane_DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function Airplane.ResetPosition()
   Airplane_DesiredPosition = nil
end

function Airplane.SetThrottle(Throttle)
   Airplane_DesiredThrottle = Clamp(Throttle, 0, 1)
end

function Airplane.GetThrottle()
   return Airplane_CurrentThrottle
end

function Airplane.ResetThrottle()
   Airplane_DesiredThrottle = nil
end

Airplane_Eps = .001

function Airplane_Classify(Index, BlockInfo, Fractions, Infos)
   local CoMOffset = BlockInfo.LocalPositionRelativeToCom
   -- Always spinners here
   local LocalForwards = BlockInfo.LocalRotation * Vector3.up
   local Info = {
      Index = Index,
      YawSign = 0,
      PitchSign = 0,
      RollSign = 0,
      ForwardSign = 0,
   }
   local UpSign = Sign(LocalForwards.y, 0, Airplane_Eps)
   if UpSign ~= 0 then
      -- Vertical
      Info.PitchSign = Sign(CoMOffset.z) * UpSign * Fractions.Pitch
      Info.RollSign = Sign(CoMOffset.x) * UpSign * Fractions.Roll
   else
      -- Horizontal
      local ForwardSign = Sign(LocalForwards.z, 0, Airplane_Eps)
      local RightSign = Sign(LocalForwards.x, 0, Airplane_Eps)
      Info.YawSign = RightSign * Sign(CoMOffset.z) * Fractions.Yaw
      Info.ForwardSign = ForwardSign * Fractions.Throttle
   end
   if Info.PitchSign ~= 0 or Info.RollSign ~= 0 or Info.YawSign ~= 0 or Info.ForwardSign ~= 0 then
      table.insert(Infos, Info)
   end
end

function Airplane_ClassifySpinners(I)
   -- Only process dediblades for now
   local SpinnerCount = I:GetDedibladeCount()
   if SpinnerCount ~= Airplane_LastSpinnerCount then
      Airplane_LastSpinnerCount = SpinnerCount
      Airplane_SpinnerInfos = {}

      for i = 0,SpinnerCount-1 do
         local BlockInfo = I:GetDedibladeInfo(i)
         Airplane_Classify(i, BlockInfo, SpinnerFractions, Airplane_SpinnerInfos)
      end
   end
end

Airplane_RequestControl = MakeRequestControl()

function Airplane.Update(I)
   local Altitude = C:Altitude()

   -- Determine target vector
   local TargetVector,DesiredHeading
   if Airplane_DesiredPosition then
      TargetVector = (Airplane_DesiredPosition - C:CoM()).normalized
      DesiredHeading = GetVectorAngle(TargetVector)
   else
      DesiredHeading = Airplane_DesiredHeading
      -- Be sure to flip sign and divide by PID scale
      local PitchForAltitude = Airplane_MaxPitch:Lookup(Altitude) * Airplane_AltitudePID:Control(Airplane_DesiredAltitude - Altitude) / -10
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

   -- Run through PIDs
   local YawCV = Airplane_YawPID:Control(Yaw)
   local PitchCV = Airplane_PitchPID:Control(Pitch)
   local RollCV = Airplane_RollPID:Control(DesiredRoll - C:Roll())

   -- And apply to controls
   Airplane_RequestControl(I, 1, YAWRIGHT, YAWLEFT, YawCV * Sign(C:ForwardSpeed(), 1))
   Airplane_RequestControl(I, 1, NOSEUP, NOSEDOWN, PitchCV)
   Airplane_RequestControl(I, 1, ROLLLEFT, ROLLRIGHT, RollCV)
   if Airplane_DesiredThrottle then
      --# Use of Airplane_RequestControl is questionable here, especially
      --# since fraction is always 1 (for now)
      Airplane_RequestControl(I, 1, MAINPROPULSION, MAINPROPULSION, Airplane_DesiredThrottle)
      Airplane_CurrentThrottle = Airplane_DesiredThrottle
   end

   if Airplane_UsesSpinners then
      Airplane_ClassifySpinners(I)

      -- Set spinner speed
      local ForwardCV = Airplane_DesiredThrottle and Airplane_DesiredThrottle or 0
      for _,Info in pairs(Airplane_SpinnerInfos) do
         -- Sum up inputs and constrain
         local Output = Clamp(YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign, -1, 1)
         I:SetDedibladeContinuousSpeed(Info.Index, 30 * Output)
      end
   end

   Airplane_Active = true
end

function Airplane.Disable(I)
   Airplane_RequestControl(I, 1, MAINPROPULSION, MAINPROPULSION, 0)
   Airplane_CurrentThrottle = 0
   if Airplane_UsesSpinners then
      Airplane_ClassifySpinners(I)
      -- And stop spinners as well
      for _,Info in pairs(Airplane_SpinnerInfos) do
         I:SetDedibladeContinuousSpeed(Info.Index, 0)
      end
   end
end

function Airplane.Release(I)
   -- Same thing as Airplane_Disable, but only done
   -- once (until Airplane_Update is called again)
   if Airplane_Active then
      Airplane.Disable(I)
      Airplane_Active = false
   end
end
