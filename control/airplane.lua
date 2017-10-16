--@ commons propulsionapi pid normalizebearing getvectorangle sign
-- Airplane module (Yaw, Pitch, Throttle)
Airplane_AltitudePID = PID.create(AirplanePIDConfig.Altitude, -10, 10)
Airplane_YawPID = PID.create(AirplanePIDConfig.Yaw, -1, 1)
Airplane_PitchPID = PID.create(AirplanePIDConfig.Pitch, -1, 1)
Airplane_RollPID = PID.create(AirplanePIDConfig.Roll, -1, 1)

Airplane_DesiredAltitude = 0
Airplane_DesiredHeading = nil
Airplane_DesiredPosition = nil
Airplane_DesiredThrottle = nil
Airplane_CurrentThrottle = 0

Airplane_LastSpinnerCount = 0
Airplane_SpinnerInfos = {}

Airplane_UsesSpinners = (SpinnerFractions.Yaw > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0 or SpinnerFractions.Throttle > 0)

-- Calculate tan ahead of time
-- Also pre-divide by the AltitudePID scaling factor
--# Divided by 2 because MaxPitch is split evenly between
--# pitch up & pitch down.
MaxPitch = math.tan(math.rad(MaxPitch / 2)) / 10

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
   Airplane_DesiredThrottle = math.max(0, math.min(1, Throttle))
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

function Airplane.Update(I)
   local Altitude = C:Altitude()

   -- Determine target vector
   local TargetVector,DesiredHeading
   if Airplane_DesiredPosition then
      TargetVector = Airplane_DesiredPosition - C:CoM()
      DesiredHeading = GetVectorAngle(TargetVector)
   else
      DesiredHeading = Airplane_DesiredHeading
      if DesiredHeading then
         local Heading = math.rad(DesiredHeading)
         TargetVector = Vector3(math.sin(Heading), 0, math.cos(Heading))
      else
         TargetVector = Vector3.forward
      end
      -- Offset by altitude
      TargetVector.y = MaxPitch * Airplane_AltitudePID:Control(Airplane_DesiredAltitude - Altitude)
   end

   TargetVector = TargetVector.normalized

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
   local Pitch = math.deg(math.atan2(TargetVector.y, z))

   -- Run through PIDs
   local YawCV = Airplane_YawPID:Control(Yaw)
   --# This is actually incorrect, but it seems to work better?
   --# Pitch is degrees relative to local, so subtracting world pitch
   --# doesn't make sense. The PV is potentially doubled though...
   local PitchCV = Airplane_PitchPID:Control(Pitch - C:Pitch())
   local RollCV = Airplane_RollPID:Control(DesiredRoll - C:Roll())

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

   if Airplane_DesiredThrottle then
      I:RequestControl(Mode, MAINPROPULSION, Airplane_DesiredThrottle)
      Airplane_CurrentThrottle = Airplane_DesiredThrottle
   end

   if Airplane_UsesSpinners then
      Airplane_ClassifySpinners(I)

      -- Set spinner speed
      local ForwardCV = Airplane_DesiredThrottle and Airplane_DesiredThrottle or 0
      for _,Info in pairs(Airplane_SpinnerInfos) do
         -- Sum up inputs and constrain
         local Output = YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign
         Output = math.max(-1, math.min(1, Output))
         I:SetSpinnerContinuousSpeed(Info.Index, 30 * Output)
      end
   end

   Airplane_Active = true
end

function Airplane.Disable(I)
   I:RequestControl(Mode, MAINPROPULSION, 0)
   Airplane_CurrentThrottle = 0
   if Airplane_UsesSpinners then
      Airplane_ClassifySpinners(I)
      -- And stop spinners as well
      for _,Info in pairs(Airplane_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
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
