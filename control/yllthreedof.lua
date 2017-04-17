--@ commons componenttypes normalizebearing sign pid thrusthack
-- YLL 3DoF module (Yaw, Longitudinal, Lateral)
YawPID = PID.create(YawPIDConfig, -30, 30)
ForwardPID = PID.create(ForwardPIDConfig, -30, 30)
RightPID = PID.create(RightPIDConfig, -30, 30)

DesiredHeading = nil
DesiredPosition = nil

-- Keep them separated for now
YLLThreeDoF_LastPropulsionCount = 0
YLLThreeDoF_PropulsionInfos = {}
YLLThreeDoF_LastSpinnerCount = 0
YLLThreeDoF_SpinnerInfos = {}

YLLThreeDoF_UsesJets = (JetFractions.Yaw > 0 or JetFractions.Forward > 0 or JetFractions.Right > 0)
YLLThreeDoF_UsesSpinners = (SpinnerFractions.Yaw > 0 or SpinnerFractions.Forward > 0 or SpinnerFractions.Right > 0)

YLLThrustHackControl = ThrustHack.create(YLLThrustHackDriveMaintainerFacing)

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

function SetPosition(Pos)
   -- Make copy to be safe
   DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function AdjustPosition(Offset)
   DesiredPosition = C:CoM() + Offset
end

function ResetPosition()
   DesiredPosition = nil
end

function YLLThreeDoF_Reset()
   ResetHeading()
   ResetPosition()
end

function YLLThreeDoF_Classify(Index, BlockInfo, IsSpinner, Fractions, Infos)
   local LocalForwards = IsSpinner and (BlockInfo.LocalRotation * Vector3.up) or BlockInfo.LocalForwards
   if math.abs(LocalForwards.y) <= 0.001 then
      -- Horizontal
      local CoMOffset = BlockInfo.LocalPositionRelativeToCom
      local RightSign = Sign(LocalForwards.x)
      local ZSign = Sign(CoMOffset.z)
      local Info = {
         Index = Index,
         YawSign = RightSign * ZSign * Fractions.Yaw,
         ForwardSign = Sign(LocalForwards.z) * Fractions.Forward,
         RightSign = RightSign * Fractions.Right,
      }
      if Info.YawSign ~= 0 or Info.ForwardSign ~= 0 or Info.RightSign ~= 0 then
         table.insert(Infos, Info)
      end
   end
end

function YLLThreeDoF_ClassifyJets(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= YLLThreeDoF_LastPropulsionCount then
      YLLThreeDoF_LastPropulsionCount = PropulsionCount
      YLLThreeDoF_PropulsionInfos = {}

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         YLLThreeDoF_Classify(i, BlockInfo, false, JetFractions, YLLThreeDoF_PropulsionInfos)
      end
   end
end

function YLLThreeDoF_ClassifySpinners(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= YLLThreeDoF_LastSpinnerCount then
      YLLThreeDoF_LastSpinnerCount = SpinnerCount
      YLLThreeDoF_SpinnerInfos = {}

      for i = 0,SpinnerCount-1 do
         -- Only process dediblades for now
         if I:IsSpinnerDedicatedHelispinner(i) then
            local BlockInfo = I:GetSpinnerInfo(i)
            YLLThreeDoF_Classify(i, BlockInfo, true, SpinnerFractions, YLLThreeDoF_SpinnerInfos)
         end
      end
   end
end

function YLLThreeDoF_Update(I)
   local YawCV = DesiredHeading and YawPID:Control(NormalizeBearing(DesiredHeading - C:Yaw())) or 0

   local ForwardCV,RightCV = 0,0
   if DesiredPosition then
      local Offset = DesiredPosition - C:CoM()
      local ZProj = Vector3.Dot(Offset, C:ForwardVector())
      local XProj = Vector3.Dot(Offset, C:RightVector())
      ForwardCV = ForwardPID:Control(ZProj)
      RightCV = RightPID:Control(XProj)
   end

   if YLLThreeDoF_UsesJets then
      YLLThreeDoF_ClassifyJets(I)

      if DesiredHeading or DesiredPosition then
         -- Blip horizontal thrusters
         if not YLLThrustHackDriveMaintainerFacing then
            for i = 0,3 do
               I:RequestThrustControl(i)
            end
         else
            YLLThrustHackControl:SetThrottle(I, 1)
         end

         -- And set drive fraction accordingly
         for _,Info in pairs(YLLThreeDoF_PropulsionInfos) do
            -- Sum up inputs and constrain
            local Output = YawCV * Info.YawSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign
            Output = math.max(0, math.min(30, Output))
            I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 30)
         end
      else
         -- Relinquish control
         YLLThrustHackControl:SetThrottle(I, 0)

         -- Restore full drive fraction for manual/stock AI control
         for _,Info in pairs(YLLThreeDoF_PropulsionInfos) do
            I:Component_SetFloatLogic(PROPULSION, Info.Index, 1)
         end
      end
   end

   if YLLThreeDoF_UsesSpinners then
      YLLThreeDoF_ClassifySpinners(I)

      if DesiredHeading or DesiredPosition then
         -- Set spinner speed
         for _,Info in pairs(YLLThreeDoF_SpinnerInfos) do
            -- Sum up inputs and constrain
            local Output = YawCV * Info.YawSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign
            Output = math.max(-30, math.min(30, Output))
            I:SetSpinnerContinuousSpeed(Info.Index, Output)
         end
      else
         for _,Info in pairs(YLLThreeDoF_SpinnerInfos) do
            -- Zero out (for now) FIXME Probably doesn't work for ACB/drive maintainer override
            I:SetSpinnerContinuousSpeed(Info.Index, 0)
         end
      end
   end
end

function YLLThreeDoF_Disable(I)
   -- Disable drive maintainers, if any
   YLLThrustHackControl:SetThrottle(I, 0)
   if YLLThreeDoF_UsesSpinners then
      YLLThreeDoF_ClassifySpinners(I)
      -- And stop spinners as well
      for _,Info in pairs(YLLThreeDoF_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
end
