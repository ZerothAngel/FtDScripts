--@ commons componenttypes propulsionapi requestcontrol normalizebearing sign pid clamp
--# Packages don't exist, and screw accessing everything through a table.
--# It's just a search/replace away to convert to 'proper' Lua anyway.
-- 6DoF module (Altitude, Yaw, Pitch, Roll, Forward/Reverse, Right/Left)
SixDoF_AltitudePID = PID.new(SixDoFPIDConfig.Altitude, -30, 30)
SixDoF_YawPID = PID.new(SixDoFPIDConfig.Yaw, -30, 30)
SixDoF_PitchPID = PID.new(SixDoFPIDConfig.Pitch, -30, 30)
SixDoF_RollPID = PID.new(SixDoFPIDConfig.Roll, -30, 30)
SixDoF_ForwardPID = PID.new(SixDoFPIDConfig.Forward, -30, 30)
SixDoF_RightPID = PID.new(SixDoFPIDConfig.Right, -30, 30)

SixDoF_DesiredAltitude = 0
SixDoF_DesiredHeading = nil
SixDoF_DesiredPosition = nil
SixDoF_DesiredThrottle = nil
SixDoF_CurrentThrottle = 0
SixDoF_DesiredPitch = 0
SixDoF_DesiredRoll = 0

-- Keep them separated for now
SixDoF_LastPropulsionCount = 0
SixDoF_PropulsionInfos = {}
SixDoF_LastSpinnerCount = 0
SixDoF_SpinnerInfos = {}

-- Figure out what's being used
SixDoF_UsesHorizontalJets = (JetFractions.Yaw > 0 or JetFractions.Forward > 0 or JetFractions.Right > 0)
SixDoF_UsesVerticalJets = (JetFractions.Altitude > 0 or JetFractions.Pitch > 0 or JetFractions.Roll > 0)
SixDoF_UsesJets = SixDoF_UsesHorizontalJets or SixDoF_UsesVerticalJets
SixDoF_UsesSpinners = (SpinnerFractions.Altitude > 0 or SpinnerFractions.Yaw > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0 or SpinnerFractions.Forward > 0 or SpinnerFractions.Right > 0)
SixDoF_UsesControls = (ControlFractions.Yaw > 0 or ControlFractions.Pitch > 0 or ControlFractions.Roll > 0 or ControlFractions.Forward > 0)

-- Through configuration, these axes can be skipped entirely
SixDoF_ControlAltitude = (JetFractions.Altitude > 0 or SpinnerFractions.Altitude > 0)
SixDoF_ControlPitch = (JetFractions.Pitch > 0 or SpinnerFractions.Pitch > 0 or ControlFractions.Pitch > 0)
SixDoF_ControlRoll = (JetFractions.Roll > 0 or SpinnerFractions.Roll > 0 or ControlFractions.Roll > 0)
-- The others (yaw/forward/right) depend on an AI

SixDoF_NeedsRelease = false

--# Public methods on the other hand...
SixDoF = {}

function SixDoF.SetAltitude(Alt)
   SixDoF_DesiredAltitude = Alt
end

function SixDoF.SetHeading(Heading)
   SixDoF_DesiredHeading = Heading % 360
end

function SixDoF.ResetHeading()
   SixDoF_DesiredHeading = nil
end

function SixDoF.SetPosition(Pos)
   -- Make copy to be safe
   SixDoF_DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function SixDoF.ResetPosition()
   SixDoF_DesiredPosition = nil
end

function SixDoF.SetThrottle(Throttle)
   SixDoF_DesiredThrottle = Clamp(Throttle, -1, 1)
end

function SixDoF.GetThrottle()
   return SixDoF_CurrentThrottle
end

function SixDoF.ResetThrottle()
   SixDoF_DesiredThrottle = nil
end

function SixDoF.SetPitch(Angle)
   SixDoF_DesiredPitch = Angle
end

function SixDoF.SetRoll(Angle)
   SixDoF_DesiredRoll = Angle
end

SixDoF_Eps = .001

function SixDoF_Classify(Index, BlockInfo, IsSpinner, Fractions, Infos)
   local CoMOffset = BlockInfo.LocalPositionRelativeToCom
   local LocalForwards = IsSpinner and (BlockInfo.LocalRotation * Vector3.up) or BlockInfo.LocalForwards
   local Info = {
      Index = Index,
      UpSign = 0,
      YawSign = 0,
      PitchSign = 0,
      RollSign = 0,
      ForwardSign = 0,
      RightSign = 0,
      IsVertical = false,
   }
   local UpSign = Sign(LocalForwards.y, 0, SixDoF_Eps)
   if UpSign ~= 0 then
      -- Vertical
      Info.UpSign = UpSign * Fractions.Altitude
      Info.PitchSign = Sign(CoMOffset.z) * UpSign * Fractions.Pitch
      Info.RollSign = Sign(CoMOffset.x) * UpSign * Fractions.Roll
      Info.IsVertical = true
   else
      -- Horizontal
      local ForwardSign = Sign(LocalForwards.z, 0, SixDoF_Eps)
      local RightSign = Sign(LocalForwards.x, 0, SixDoF_Eps)
      Info.YawSign = RightSign * Sign(CoMOffset.z) * Fractions.Yaw
      Info.ForwardSign = ForwardSign * Fractions.Forward
      Info.RightSign = RightSign * Fractions.Right
   end
   if Info.UpSign ~= 0 or Info.PitchSign ~= 0 or Info.RollSign ~= 0 or Info.YawSign ~= 0 or Info.ForwardSign ~= 0 or Info.RightSign ~= 0 then
      table.insert(Infos, Info)
   end
end

function SixDoF_ClassifyJets(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= SixDoF_LastPropulsionCount then
      SixDoF_LastPropulsionCount = PropulsionCount
      SixDoF_PropulsionInfos = {}

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         SixDoF_Classify(i, BlockInfo, false, JetFractions, SixDoF_PropulsionInfos)
      end
   end
end

function SixDoF_ClassifySpinners(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= SixDoF_LastSpinnerCount then
      SixDoF_LastSpinnerCount = SpinnerCount
      SixDoF_SpinnerInfos = {}

      for i = 0,SpinnerCount-1 do
         -- Only process dediblades for now
         if I:IsSpinnerDedicatedHelispinner(i) then
            local BlockInfo = I:GetSpinnerInfo(i)
            SixDoF_Classify(i, BlockInfo, true, SpinnerFractions, SixDoF_SpinnerInfos)
         end
      end

      if DediBladesAlwaysUp then
         -- Flip signs on any spinners with negative UpSign
         for _,Info in pairs(SixDoF_SpinnerInfos) do
            local UpSign = Info.UpSign
            if UpSign < 0 then
               Info.UpSign = -UpSign
               Info.PitchSign = -Info.PitchSign
               Info.RollSign = -Info.RollSign
            end
         end
      end
   end
end

SixDoF_RequestControl = MakeRequestControl(1/30)

function SixDoF.Update(I)
   local AltitudeCV = 0
   if SixDoF_ControlAltitude then
      local AltitudeDelta = SixDoF_DesiredAltitude - C:Altitude()
      if not DediBladesAlwaysUp then
         -- Scale by vehicle up vector's Y component
         AltitudeDelta = AltitudeDelta * C:UpVector().y
      end
      -- Otherwise, the assumption is that it always points straight up
      -- ("always up")
      AltitudeCV = SixDoF_AltitudePID:Control(AltitudeDelta)
   end
   local YawCV = SixDoF_DesiredHeading and SixDoF_YawPID:Control(NormalizeBearing(SixDoF_DesiredHeading - C:Yaw())) or 0
   local PitchCV = SixDoF_ControlPitch and SixDoF_PitchPID:Control(SixDoF_DesiredPitch - C:Pitch()) or 0
   local RollCV = SixDoF_ControlRoll and SixDoF_RollPID:Control(SixDoF_DesiredRoll - C:Roll()) or 0

   local ForwardCV,RightCV = 0,0
   if SixDoF_DesiredPosition then
      local Offset = SixDoF_DesiredPosition - C:CoM()
      local ZProj = Vector3.Dot(Offset, C:ForwardVector())
      local XProj = Vector3.Dot(Offset, C:RightVector())
      ForwardCV = SixDoF_ForwardPID:Control(ZProj)
      RightCV = SixDoF_RightPID:Control(XProj)
   elseif SixDoF_DesiredThrottle then
      ForwardCV = 30 * SixDoF_DesiredThrottle -- PID is scaled, so scale up
      SixDoF_CurrentThrottle = SixDoF_DesiredThrottle
   end

   local PlanarMovement = SixDoF_DesiredHeading or SixDoF_DesiredPosition or SixDoF_DesiredThrottle

   if SixDoF_UsesJets then
      SixDoF_ClassifyJets(I)

      if SixDoF_UsesHorizontalJets and PlanarMovement then
         -- Blip horizontal thrusters
         if not YLLThrustHackKey then
            for i = 0,3 do
               I:RequestThrustControl(i)
            end
         else
            I:RequestComplexControllerStimulus(YLLThrustHackKey)
         end
      end
      if SixDoF_UsesVerticalJets then
         -- Blip top & bottom thrusters
         if not APRThrustHackKey then
            I:RequestThrustControl(4)
            I:RequestThrustControl(5)
         else
            I:RequestComplexControllerStimulus(APRThrustHackKey)
         end
      end

      -- Set drive fraction accordingly
      for _,Info in pairs(SixDoF_PropulsionInfos) do
         if Info.IsVertical or PlanarMovement then
            -- Sum up inputs and constrain
            local Output = Clamp(AltitudeCV * Info.UpSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign, 0, 30)
            I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 30)
         else
            -- Restore full drive fraction for manual/stock AI control
            I:Component_SetFloatLogic(PROPULSION, Info.Index, 1)
         end
      end
   end

   if SixDoF_UsesSpinners then
      SixDoF_ClassifySpinners(I)

      -- Set spinner speed
      for _,Info in pairs(SixDoF_SpinnerInfos) do
         if Info.IsVertical or PlanarMovement then
            -- Sum up inputs and constrain
            local Output = Clamp(AltitudeCV * Info.UpSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign, -30, 30)
            I:SetSpinnerContinuousSpeed(Info.Index, Output)
         end
      end
   end

   if SixDoF_UsesControls then
      SixDoF_RequestControl(I, ControlFractions.Pitch, NOSEUP, NOSEDOWN, PitchCV)
      SixDoF_RequestControl(I, ControlFractions.Roll, ROLLLEFT, ROLLRIGHT, RollCV)
      if PlanarMovement then
         SixDoF_RequestControl(I, ControlFractions.Yaw, YAWRIGHT, YAWLEFT, YawCV * Sign(C:ForwardSpeed(), 1))
         SixDoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, ForwardCV)
      end
   end

   if PlanarMovement then
      SixDoF_NeedsRelease = true
   end
end

function SixDoF.Disable(I)
   SixDoF_CurrentThrottle = 0
   if SixDoF_UsesSpinners then
      SixDoF_ClassifySpinners(I)
      -- Stop spinners
      for _,Info in pairs(SixDoF_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
   if SixDoF_UsesControls then
      -- Only MAINPROPULSION is stateful
      SixDoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, 0)
   end
end

function SixDoF.Release(I)
   -- Disable non-vertical spinners just once
   if SixDoF_NeedsRelease then
      if SixDoF_UsesSpinners then
         SixDoF_ClassifySpinners(I)
         for _,Info in pairs(SixDoF_SpinnerInfos) do
            if not Info.IsVertical then
               I:SetSpinnerContinuousSpeed(Info.Index, 0)
            end
         end
      end
      SixDoF_NeedsRelease = false
   end
end
