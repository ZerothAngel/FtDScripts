--@ commons propulsionapi pid normalizebearing sign
-- Airplane module (Yaw, Pitch, Throttle)
AltitudePID = PID.create(AltitudePIDConfig, -10, 10)
YawPID = PID.create(YawPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)
RollPID = PID.create(RollPIDConfig, -1, 1)

DesiredAltitude = 0
DesiredHeading = nil
DesiredPitch = 0
DesiredRoll = 0
DesiredThrottle = nil
CurrentThrottle = 0

function SetAltitude(Alt)
   DesiredAltitude = Alt
end

function AdjustAltitude(Delta) -- luacheck: ignore 131
   SetAltitude(C:Altitude() + Delta)
end

-- Sets heading to an absolute value, 0 is north, 90 is east
function SetHeading(Heading)
   DesiredHeading = Heading % 360
end

-- Adjusts heading toward relative bearing
function AdjustHeading(Bearing) -- luacheck: ignore 131
   SetHeading(C:Yaw() + Bearing)
end

-- Resets heading so yaw will no longer be modified
function ResetHeading()
   DesiredHeading = nil
end

-- Sets throttle. Throttle should be [-1, 1]
function SetThrottle(Throttle)
   DesiredThrottle = math.max(0, math.min(1, Throttle))
end

-- Adjusts throttle by some delta
function AdjustThrottle(Delta) -- luacheck: ignore 131
   SetThrottle(CurrentThrottle + Delta)
end

-- Resets throttle so drives will no longer be modified
function ResetThrottle()
   DesiredThrottle = nil
end

function Airplane_Reset()
   ResetHeading()
   ResetThrottle()
end

function Airplane_Update(I)
   local Altitude = C:Altitude()

   local TargetVector = Vector3.forward
   if DesiredHeading then
      TargetVector = Quaternion.Euler(0, DesiredHeading, 0) * TargetVector
      local Bearing = NormalizeBearing(DesiredHeading - GetVectorAngle(C:ForwardVector()))
      if AngleBeforeRoll and math.abs(Bearing) > AngleBeforeRoll and Altitude >= MinAltitudeForRoll then
         local DeltaBearing = math.abs(Bearing) - AngleBeforeRoll
         local RollAngle = RollAngleGain and math.min(MaxRollAngle, DeltaBearing * RollAngleGain) or MaxRollAngle
         DesiredRoll = Sign(Bearing) * -RollAngle
      else
         DesiredRoll = 0
      end
   else
      DesiredRoll = 0
   end

   local AltitudeDelta = DesiredAltitude - Altitude

   -- Figure out pitch limits for this altitude
   local MinPitch,MaxPitch
   Altitude = math.max(0, Altitude)
   for _,MaxPitchInfo in pairs(MaxPitchAngles) do
      if Altitude >= MaxPitchInfo[1] then
         MinPitch = MaxPitchInfo[2]
         MaxPitch = MaxPitchInfo[3]
      else
         break
      end
   end

   -- Offset by altitude and re-normalize
   TargetVector.y = AltitudePID:Control(AltitudeDelta) / 10
   TargetVector = TargetVector.normalized

   -- Convert to local coordinates
   TargetVector = C:ToLocal() * TargetVector

   -- Determine angles
   local z = TargetVector.z
   local Yaw = math.deg(math.atan2(TargetVector.x, z))
   local Pitch = math.deg(math.atan2(TargetVector.y, z))

   -- Constrain pitch
   DesiredPitch = C:Pitch() + Pitch
   DesiredPitch = math.max(MinPitch, math.min(MaxPitch, DesiredPitch))

   -- Run through PIDs
   local YawCV = YawPID:Control(Yaw)
   local PitchCV = PitchPID:Control(DesiredPitch - C:Pitch())
   local RollCV = RollPID:Control(DesiredRoll - C:Roll())

   -- And apply to controls
   if YawCV > 0 then
      I:RequestControl(Mode, YAWRIGHT, YawCV)
   elseif YawCV < 0 then
      I:RequestControl(Mode, YAWLEFT, -YawCV)
   end

   if PitchCV > 0 then
      I:RequestControl(Mode, NOSEUP, PitchCV)
   elseif PitchCV < 0 then
      I:RequestControl(Mode, NOSEDOWN, -PitchCV)
   end

   if RollCV > 0 then
      I:RequestControl(Mode, ROLLLEFT, RollCV)
   elseif RollCV < 0 then
      I:RequestControl(Mode, ROLLRIGHT, -RollCV)
   end

   if DesiredThrottle then
      I:RequestControl(Mode, MAINPROPULSION, DesiredThrottle)
      CurrentThrottle = DesiredThrottle
   end
end

function Airplane_Disable(I)
   I:RequestControl(Mode, MAINPROPULSION, 0)
   CurrentThrottle = 0
end
