--@ commons componenttypes propulsionapi normalizebearing sign pid thrusthack
-- 6DoF module (Altitude, Yaw, Pitch, Roll, Forward/Reverse, Right/Left)
AltitudePID = PID.create(AltitudePIDConfig, -30, 30)
YawPID = PID.create(YawPIDConfig, -30, 30)
PitchPID = PID.create(PitchPIDConfig, -30, 30)
RollPID = PID.create(RollPIDConfig, -30, 30)
ForwardPID = PID.create(ForwardPIDConfig, -30, 30)
RightPID = PID.create(RightPIDConfig, -30, 30)

DesiredAltitude = 0
DesiredHeading = nil
DesiredPosition = nil
DesiredThrottle = nil
CurrentThrottle = 0
DesiredPitch = 0
DesiredRoll = 0

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

APRThrustHackControl = ThrustHack.create(APRThrustHackDriveMaintainerFacing)
YLLThrustHackControl = ThrustHack.create(YLLThrustHackDriveMaintainerFacing)

function SetAltitude(Alt) -- luacheck: ignore 131
   DesiredAltitude = Alt
end

function AdjustAltitude(Delta) -- luacheck: ignore 131
   SetAltitude(C:Altitude() + Delta)
end

-- Sets heading to an absolute value, 0 is north, 90 is east
function SetHeading(Heading) -- luacheck: ignore 131
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

function SetPosition(Pos) -- luacheck: ignore 131
   -- Make copy to be safe
   DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function AdjustPosition(Offset) -- luacheck: ignore 131
   DesiredPosition = C:CoM() + Offset
end

function ResetPosition()
   DesiredPosition = nil
end

-- Sets throttle. Throttle should be [-1, 1]
function SetThrottle(Throttle) -- luacheck: ignore 131
   DesiredThrottle = math.max(-1, math.min(1, Throttle))
end

-- Adjusts throttle by some delta
function AdjustThrottle(Delta) -- luacheck: ignore 131
   SetThrottle(CurrentThrottle + Delta)
end

-- Resets throttle so drives will no longer be modified
function ResetThrottle()
   DesiredThrottle = nil
end

function SetPitch(Angle) -- luacheck: ignore 131
   DesiredPitch = Angle
end

function SetRoll(Angle) -- luacheck: ignore 131
   DesiredRoll = Angle
end

function SixDoF_Reset() -- luacheck: ignore 131
   ResetHeading()
   ResetPosition()
   ResetThrottle()
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

function SixDoF_RequestControl(I, Fraction, PosControl, NegControl, CV)
   if Fraction > 0 then
      -- Scale down and constrain
      CV = math.max(-1, math.min(1, Fraction * CV / 30))
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

function SixDoF_Update(I)
   local AltitudeCV = 0
   if SixDoF_ControlAltitude then
      local AltitudeDelta = DesiredAltitude - C:Altitude()
      if not DediBladesAlwaysUp then
         -- Scale by vehicle up vector's Y component
         AltitudeDelta = AltitudeDelta * C:UpVector().y
      end
      -- Otherwise, the assumption is that it always points straight up
      -- ("always up")
      AltitudeCV = AltitudePID:Control(AltitudeDelta)
   end
   local YawCV = DesiredHeading and YawPID:Control(NormalizeBearing(DesiredHeading - C:Yaw())) or 0
   local PitchCV = SixDoF_ControlPitch and PitchPID:Control(DesiredPitch - C:Pitch()) or 0
   local RollCV = SixDoF_ControlRoll and RollPID:Control(DesiredRoll - C:Roll()) or 0

   local ForwardCV,RightCV = 0,0
   if DesiredPosition then
      local Offset = DesiredPosition - C:CoM()
      local ZProj = Vector3.Dot(Offset, C:ForwardVector())
      local XProj = Vector3.Dot(Offset, C:RightVector())
      ForwardCV = ForwardPID:Control(ZProj)
      RightCV = RightPID:Control(XProj)
   elseif DesiredThrottle then
      ForwardCV = 30 * DesiredThrottle -- PID is scaled, so scale up
      CurrentThrottle = DesiredThrottle
   end

   local PlanarMovement = DesiredHeading or DesiredPosition or DesiredThrottle

   if SixDoF_UsesJets then
      SixDoF_ClassifyJets(I)

      if SixDoF_UsesHorizontalJets and PlanarMovement then
         -- Blip horizontal thrusters
         if not YLLThrustHackDriveMaintainerFacing then
            for i = 0,3 do
               I:RequestThrustControl(i)
            end
         else
            YLLThrustHackControl:SetThrottle(I, 1)
         end
      else
         -- Relinquish control
         YLLThrustHackControl:SetThrottle(I, 0)
      end
      if SixDoF_UsesVerticalJets then
         -- Blip top & bottom thrusters
         if not APRThrustHackDriveMaintainerFacing then
            I:RequestThrustControl(4)
            I:RequestThrustControl(5)
         else
            APRThrustHackControl:SetThrottle(I, 1)
         end
      end

      -- Set drive fraction accordingly
      for _,Info in pairs(SixDoF_PropulsionInfos) do
         if Info.IsVertical or PlanarMovement then
            -- Sum up inputs and constrain
            local Output = AltitudeCV * Info.UpSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign
            Output = math.max(0, math.min(30, Output))
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
            local Output = AltitudeCV * Info.UpSign + YawCV * Info.YawSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign
            Output = math.max(-30, math.min(30, Output))
            I:SetSpinnerContinuousSpeed(Info.Index, Output)
         else
            -- Zero out (for now) FIXME Probably doesn't work for ACB/drive maintainer override
            I:SetSpinnerContinuousSpeed(Info.Index, 0)
         end
      end
   end

   if SixDoF_UsesControls then
      SixDoF_RequestControl(I, ControlFractions.Pitch, NOSEUP, NOSEDOWN, PitchCV)
      SixDoF_RequestControl(I, ControlFractions.Roll, ROLLLEFT, ROLLRIGHT, RollCV)
      if PlanarMovement then
         SixDoF_RequestControl(I, ControlFractions.Yaw, YAWRIGHT, YAWLEFT, YawCV)
         SixDoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, ForwardCV)
      end
   end
end

function SixDoF_Disable(I)
   CurrentThrottle = 0
   -- Disable drive maintainers, if any
   APRThrustHackControl:SetThrottle(I, 0)
   YLLThrustHackControl:SetThrottle(I, 0)
   if SixDoF_UsesSpinners then
      SixDoF_ClassifySpinners(I)
      -- And stop spinners as well
      for _,Info in pairs(SixDoF_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
   if SixDoF_UsesControls then
      -- Only MAINPROPULSION is stateful
      SixDoF_RequestControl(I, ControlFractions.Forward, MAINPROPULSION, MAINPROPULSION, 0)
   end
end
