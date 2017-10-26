--@ commons componenttypes propulsionapi normalizebearing sign pid clamp
-- All DoF module
AllDoF_AltitudePID = PID.new(AllDoFPIDConfig.Altitude, -30, 30)
AllDoF_YawPID = PID.new(AllDoFPIDConfig.Yaw, -30, 30)
AllDoF_PitchPID = PID.new(AllDoFPIDConfig.Pitch, -30, 30)
AllDoF_RollPID = PID.new(AllDoFPIDConfig.Roll, -30, 30)
AllDoF_NorthPID = PID.new(AllDoFPIDConfig.North, -30, 30)
AllDoF_EastPID = PID.new(AllDoFPIDConfig.East, -30, 30)

AllDoF_DesiredAltitude = 0
AllDoF_DesiredHeading = nil
AllDoF_DesiredPosition = nil
AllDoF_DesiredThrottle = nil
AllDoF_CurrentThrottle = 0
AllDoF_DesiredPitch = 0
AllDoF_DesiredRoll = 0

-- Figure out what's being used
AllDoF_UsesJets = (JetFractions.Altitude > 0 or JetFractions.Yaw > 0 or JetFractions.Pitch > 0 or JetFractions.Roll > 0 or JetFractions.North > 0 or JetFractions.East > 0 or JetFractions.Forward > 0)
AllDoF_UsesSpinners = (SpinnerFractions.Altitude > 0 or SpinnerFractions.Yaw > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0 or SpinnerFractions.North > 0 or SpinnerFractions.East > 0 or SpinnerFractions.Forward > 0)
AllDoF_UsesControls = (ControlFractions.Yaw > 0 or ControlFractions.Pitch > 0 or ControlFractions.Roll > 0 or ControlFractions.Forward > 0)

AllDoF = {}

function AllDoF.SetAltitude(Alt)
   AllDoF_DesiredAltitude = Alt
end

function AllDoF.SetHeading(Heading)
   AllDoF_DesiredHeading = Heading % 360
end

function AllDoF.ResetHeading()
   AllDoF_DesiredHeading = nil
end

function AllDoF.SetPosition(Pos)
   -- Make copy to be safe
   AllDoF_DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function AllDoF.ResetPosition()
   AllDoF_DesiredPosition = nil
end

function AllDoF.SetThrottle(Throttle)
   AllDoF_DesiredThrottle = Clamp(Throttle, -1, 1)
end

function AllDoF.GetThrottle()
   return AllDoF_CurrentThrottle
end

function AllDoF.ResetThrottle()
   AllDoF_DesiredThrottle = nil
end

function AllDoF.SetPitch(Angle)
   AllDoF_DesiredPitch = Angle
end

function AllDoF.SetRoll(Angle)
   AllDoF_DesiredRoll = Angle
end

AllDoF_Eps = .001

function AllDoF_Classify(Index, BlockInfo, IsSpinner, Fractions, Infos)
   -- Derive everything from world position/rotation
   local Forwards = IsSpinner and (BlockInfo.Rotation * Vector3.up) or BlockInfo.Forwards
   local LocalForwards = C:ToLocal() * Forwards
   local CoMOffset = C:ToLocal() * (BlockInfo.Position - C:CoM())

   local UpSign = LocalForwards.y
   local ForwardSign = LocalForwards.z

   local CoMOffsetX = Sign(CoMOffset.x, 0, AllDoF_Eps)
   local CoMOffsetZ = Sign(CoMOffset.z, 0, AllDoF_Eps)

   local Info = {
      Index = Index,
      AltitudeSign = Forwards.y * Fractions.Altitude,
      YawSign = (LocalForwards.x * CoMOffsetZ - ForwardSign * CoMOffsetX) * Fractions.Yaw,
      PitchSign = UpSign * CoMOffsetZ * Fractions.Pitch,
      RollSign = UpSign * CoMOffsetX * Fractions.Roll,
      NorthSign = Forwards.z * Fractions.North,
      EastSign = Forwards.x * Fractions.East,
      ForwardSign = ForwardSign * Fractions.Forward,
   }
   if Info.AltitudeSign ~= 0 or Info.YawSign ~= 0 or Info.PitchSign ~= 0 or Info.RollSign ~= 0 or Info.NorthSign ~= 0 or Info.EastSign ~= 0 then
      table.insert(Infos, Info)
   end
end

function AllDoF_ClassifyJets(I)
   local Infos = {}

   for i = 0,I:Component_GetCount(PROPULSION)-1 do
      local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
      AllDoF_Classify(i, BlockInfo, false, JetFractions, Infos)
   end

   return Infos
end

function AllDoF_ClassifySpinners(I)
   local Infos = {}

   for i = 0,I:GetSpinnerCount()-1 do
      if I:IsSpinnerDedicatedHelispinner(i) then
         local BlockInfo = I:GetSpinnerInfo(i)
         AllDoF_Classify(i, BlockInfo, true, SpinnerFractions, Infos)
      end
   end

   return Infos
end

function AllDoF_RequestControl(I, Fraction, PosControl, NegControl, CV)
   if Fraction > 0 then
      -- Scale down and constrain
      CV = Clamp(Fraction * CV / 30, -1, 1)
      if PosControl ~= NegControl then
         -- Generally yaw, pitch, roll
         if CV > 0 then
            I:RequestControl(Mode, PosControl, CV)
         elseif CV < 0 then
            I:RequestControl(Mode, NegControl, -CV)
         end
      else
         -- Generally propulsion
         I:RequestControl(Mode, PosControl, CV)
      end
   end
end

function AllDoF.Update(I)
   local YawCV = AllDoF_DesiredHeading and AllDoF_YawPID:Control(NormalizeBearing(AllDoF_DesiredHeading - C:Yaw())) or 0
   local PitchCV = AllDoF_PitchPID:Control(AllDoF_DesiredPitch - C:Pitch())
   local RollCV = AllDoF_RollPID:Control(AllDoF_DesiredRoll - C:Roll())
   local AltitudeCV = AllDoF_AltitudePID:Control(AllDoF_DesiredAltitude - C:Altitude())
   local NorthCV,EastCV,ForwardCV = 0,0,0
   if AllDoF_DesiredPosition then
      local Offset = AllDoF_DesiredPosition - C:CoM()
      NorthCV = AllDoF_NorthPID:Control(Offset.z)
      EastCV = AllDoF_EastPID:Control(Offset.x)
   elseif AllDoF_DesiredThrottle then
      ForwardCV = 30 * AllDoF_DesiredThrottle
      AllDoF_CurrentThrottle = AllDoF_DesiredThrottle
   end

   if AllDoF_UsesJets then
      local Infos = AllDoF_ClassifyJets(I)

      -- Blip EVERYTHING
      if not ThrustHackKey then
         for i = 0,5 do
            I:RequestThrustControl(i)
         end
      else
         I:RequestComplexControllerStimulus(ThrustHackKey)
      end

      -- Set drive fraction accordingly
      for _,Info in pairs(Infos) do
         -- Sum up inputs and constrain
         local Output = Clamp(AltitudeCV * Info.AltitudeSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + NorthCV * Info.NorthSign + EastCV * Info.EastSign + ForwardCV * Info.ForwardSign, 0, 30)
         I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 30)
      end
   end

   if AllDoF_UsesSpinners then
      local Infos = AllDoF_ClassifySpinners(I)

      -- Set spinner speed
      for _,Info in pairs(Infos) do
         -- Sum up inputs and constrain
         local Output = Clamp(AltitudeCV * Info.AltitudeSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + NorthCV * Info.NorthSign + EastCV * Info.EastSign + ForwardCV * Info.ForwardSign, -30, 30)
         I:SetSpinnerContinuousSpeed(Info.Index, Output)
      end
   end

   if AllDoF_UsesControls then
      AllDoF_RequestControl(I, ControlFractions.Yaw, YAWRIGHT, YAWLEFT, YawCV)
      AllDoF_RequestControl(I, ControlFractions.Pitch, NOSEUP, NOSEDOWN, PitchCV)
      AllDoF_RequestControl(I, ControlFractions.Roll, ROLLLEFT, ROLLRIGHT, RollCV)
      AllDoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, ForwardCV)
   end
end

function AllDoF.Disable(I)
   AllDoF_CurrentThrottle = 0
   if AllDoF_UsesSpinners then
      local Infos = AllDoF_ClassifySpinners(I)
      -- Stop spinners
      for _,Info in pairs(Infos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
end
