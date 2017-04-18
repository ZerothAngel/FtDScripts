--@ commons propulsionapi pid normalizebearing getvectorangle sign
-- Airplane module (Yaw, Pitch, Throttle)
AltitudePID = PID.create(AltitudePIDConfig, -10, 10)
YawPID = PID.create(YawPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)
RollPID = PID.create(RollPIDConfig, -1, 1)

DesiredAltitude = 0
DesiredHeading = nil
DesiredRoll = 0
DesiredThrottle = nil
CurrentThrottle = 0

Airplane_LastSpinnerCount = 0
Airplane_SpinnerInfos = {}

Airplane_UsesSpinners = (SpinnerFractions.Yaw > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0 or SpinnerFractions.Throttle > 0)

MaxPitch = math.tan(math.rad(MaxPitch))

Airplane_Active = false

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
   if math.abs(LocalForwards.y) > 0.001 then
      -- Vertical
      local UpSign = Sign(LocalForwards.y)
      Info.PitchSign = Sign(CoMOffset.z) * UpSign * Fractions.Pitch
      Info.RollSign = Sign(CoMOffset.x) * UpSign * Fractions.Roll
   else
      -- Horizontal
      local RightSign = Sign(LocalForwards.x)
      local ZSign = Sign(CoMOffset.z)
      Info.YawSign = RightSign * ZSign * Fractions.Yaw
      Info.ForwardSign = Sign(LocalForwards.z) * Fractions.Throttle
   end
   if Info.PitchSign ~= 0 or Info.RollSign ~= 0 or Info.YawSign ~= 0 or Info.ForwardSign ~= 0 then
      table.insert(Infos, Info)
   end
end

function Airplane_ClassifySpinners(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= Airplane_LastSpinnerCount then
      Airplane_LastSpinnerCount = SpinnerCount
      Airplane_SpinnerInfos = {}

      for i = 0,SpinnerCount-1 do
         -- Only process dediblades for now
         if I:IsSpinnerDedicatedHelispinner(i) then
            local BlockInfo = I:GetSpinnerInfo(i)
            Airplane_Classify(i, BlockInfo, SpinnerFractions, Airplane_SpinnerInfos)
         end
      end
   end
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

   -- Offset by altitude and re-normalize
   TargetVector.y = MaxPitch * AltitudePID:Control(DesiredAltitude - Altitude) / 10
   TargetVector = TargetVector.normalized

   -- Convert to local coordinates
   TargetVector = C:ToLocal() * TargetVector

   -- Determine angles
   local z = TargetVector.z
   local Yaw = math.deg(math.atan2(TargetVector.x, z))
   local Pitch = math.deg(math.atan2(TargetVector.y, z))

   -- Run through PIDs
   local YawCV = YawPID:Control(Yaw)
   local PitchCV = PitchPID:Control(Pitch)
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

   if Airplane_UsesSpinners then
      Airplane_ClassifySpinners(I)

      -- Set spinner speed
      local ForwardCV = DesiredThrottle and DesiredThrottle or 0
      for _,Info in pairs(Airplane_SpinnerInfos) do
         -- Sum up inputs and constrain
         local Output = YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign
         Output = math.max(-1, math.min(1, Output))
         I:SetSpinnerContinuousSpeed(Info.Index, 30 * Output)
      end
   end

   Airplane_Active = true
end

function Airplane_Disable(I)
   I:RequestControl(Mode, MAINPROPULSION, 0)
   CurrentThrottle = 0
   if Airplane_UsesSpinners then
      Airplane_ClassifySpinners(I)
      -- And stop spinners as well
      for _,Info in pairs(Airplane_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
end

function Airplane_Release(I)
   -- Same thing as Airplane_Disable, but only done
   -- once (until Airplane_Update is called again)
   if Airplane_Active then
      Airplane_Disable(I)
      Airplane_Active = false
   end
end
