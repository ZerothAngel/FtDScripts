--@ commons componenttypes propulsionapi requestcontrol normalizebearing sign pid clamp
-- All DoF module
True6DoF_AltitudePID = PID.new(True6DoFPIDConfig.Altitude, -30, 30)
True6DoF_YawPID = PID.new(True6DoFPIDConfig.Yaw, -30, 30)
True6DoF_PitchPID = PID.new(True6DoFPIDConfig.Pitch, -30, 30)
True6DoF_RollPID = PID.new(True6DoFPIDConfig.Roll, -30, 30)
True6DoF_NorthPID = PID.new(True6DoFPIDConfig.North, -30, 30)
True6DoF_EastPID = PID.new(True6DoFPIDConfig.East, -30, 30)

True6DoF_DesiredAltitude = 0
True6DoF_DesiredHeading = nil
True6DoF_DesiredPosition = nil
True6DoF_DesiredThrottle = nil
True6DoF_CurrentThrottle = 0
True6DoF_DesiredPitch = 0
True6DoF_DesiredRoll = 0

-- Figure out what's being used
True6DoF_UsesJets = (JetFractions.Altitude > 0 or JetFractions.Yaw > 0 or JetFractions.Pitch > 0 or JetFractions.Roll > 0 or JetFractions.North > 0 or JetFractions.East > 0 or JetFractions.Forward > 0)
True6DoF_UsesSpinners = (SpinnerFractions.Altitude > 0 or SpinnerFractions.Yaw > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0 or SpinnerFractions.North > 0 or SpinnerFractions.East > 0 or SpinnerFractions.Forward > 0)
True6DoF_UsesControls = (ControlFractions.Yaw > 0 or ControlFractions.Pitch > 0 or ControlFractions.Roll > 0 or ControlFractions.Forward > 0)

True6DoF = {}

function True6DoF.SetAltitude(Alt)
   True6DoF_DesiredAltitude = Alt
end

function True6DoF.SetHeading(Heading)
   True6DoF_DesiredHeading = Heading % 360
end

function True6DoF.ResetHeading()
   True6DoF_DesiredHeading = nil
end

function True6DoF.SetPosition(Pos)
   -- Make copy to be safe
   True6DoF_DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function True6DoF.ResetPosition()
   True6DoF_DesiredPosition = nil
end

function True6DoF.SetThrottle(Throttle)
   True6DoF_DesiredThrottle = Clamp(Throttle, -1, 1)
end

function True6DoF.GetThrottle()
   return True6DoF_CurrentThrottle
end

function True6DoF.ResetThrottle()
   True6DoF_DesiredThrottle = nil
end

function True6DoF.SetPitch(Angle)
   True6DoF_DesiredPitch = Angle
end

function True6DoF.SetRoll(Angle)
   True6DoF_DesiredRoll = Angle
end

True6DoF_Eps = .001

function True6DoF_Classify(Index, BlockInfo, IsSpinner, Fractions, Infos)
   -- Derive everything from world position/rotation
   local Forwards = IsSpinner and (BlockInfo.Rotation * Vector3.up) or BlockInfo.Forwards
   local LocalForwards = C:ToLocal() * Forwards
   local CoMOffset = C:ToLocal() * (BlockInfo.Position - C:CoM())

   local UpSign = LocalForwards.y
   local ForwardSign = LocalForwards.z

   local CoMOffsetX = Sign(CoMOffset.x, 0, True6DoF_Eps)
   local CoMOffsetZ = Sign(CoMOffset.z, 0, True6DoF_Eps)

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

function True6DoF_ClassifyJets(I)
   local Infos = {}

   for i = 0,I:Component_GetCount(PROPULSION)-1 do
      local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
      True6DoF_Classify(i, BlockInfo, false, JetFractions, Infos)
   end

   return Infos
end

function True6DoF_ClassifySpinners(I)
   local Infos = {}

   for i = 0,I:GetDedibladeCount()-1 do
      local BlockInfo = I:GetDedibladeInfo(i)
      True6DoF_Classify(i, BlockInfo, true, SpinnerFractions, Infos)
   end

   return Infos
end

True6DoF_RequestControl = MakeRequestControl(1/30)

function True6DoF.Update(I)
   local YawCV = True6DoF_DesiredHeading and True6DoF_YawPID:Control(NormalizeBearing(True6DoF_DesiredHeading - C:Yaw())) or 0
   local PitchCV = True6DoF_PitchPID:Control(True6DoF_DesiredPitch - C:Pitch())
   local RollCV = True6DoF_RollPID:Control(True6DoF_DesiredRoll - C:Roll())
   local AltitudeCV = True6DoF_AltitudePID:Control(True6DoF_DesiredAltitude - C:Altitude())
   local NorthCV,EastCV,ForwardCV = 0,0,0
   if True6DoF_DesiredPosition then
      local Offset = True6DoF_DesiredPosition - C:CoM()
      NorthCV = True6DoF_NorthPID:Control(Offset.z)
      EastCV = True6DoF_EastPID:Control(Offset.x)
   elseif True6DoF_DesiredThrottle then
      ForwardCV = 30 * True6DoF_DesiredThrottle
      True6DoF_CurrentThrottle = True6DoF_DesiredThrottle
   end

   if True6DoF_UsesJets then
      local Infos = True6DoF_ClassifyJets(I)

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

   if True6DoF_UsesSpinners then
      local Infos = True6DoF_ClassifySpinners(I)

      -- Set spinner speed
      for _,Info in pairs(Infos) do
         -- Sum up inputs and constrain
         local Output = Clamp(AltitudeCV * Info.AltitudeSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + NorthCV * Info.NorthSign + EastCV * Info.EastSign + ForwardCV * Info.ForwardSign, -30, 30)
         I:SetDedibladeContinuousSpeed(Info.Index, Output)
      end
   end

   if True6DoF_UsesControls then
      True6DoF_RequestControl(I, ControlFractions.Yaw, YAWRIGHT, YAWLEFT, YawCV * Sign(C:ForwardSpeed(), 1))
      True6DoF_RequestControl(I, ControlFractions.Pitch, NOSEUP, NOSEDOWN, PitchCV)
      True6DoF_RequestControl(I, ControlFractions.Roll, ROLLLEFT, ROLLRIGHT, RollCV)
      True6DoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, ForwardCV)
   end
end

function True6DoF.Disable(I)
   True6DoF_CurrentThrottle = 0
   if True6DoF_UsesSpinners then
      local Infos = True6DoF_ClassifySpinners(I)
      -- Stop spinners
      for _,Info in pairs(Infos) do
         I:SetDedibladeContinuousSpeed(Info.Index, 0)
      end
   end
   if True6DoF_UsesControls then
      True6DoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, 0)
   end
end
