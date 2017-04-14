--@ commons sign pid thrusthack
-- APR 3DoF module (Altitude, Pitch, Roll)
AltitudePID = PID.create(AltitudePIDConfig, -30, 30)
PitchPID = PID.create(PitchPIDConfig, -30, 30)
RollPID = PID.create(RollPIDConfig, -30, 30)

DesiredAltitude = 0
DesiredPitch = 0
DesiredRoll = 0

-- Keep them separated for now
APRThreeDoF_LastPropulsionCount = 0
APRThreeDoF_PropulsionInfos = {}
APRThreeDoF_LastSpinnerCount = 0
APRThreeDoF_SpinnerInfos = {}

APRThreeDoF_UsesJets = (JetFractions.Altitude > 0 or JetFractions.Pitch > 0 or JetFractions.Roll > 0)
APRThreeDoF_UsesSpinners = (SpinnerFractions.Altitude > 0 or SpinnerFractions.Pitch > 0 or SpinnerFractions.Roll > 0)

APRThrustHackControl = ThrustHack.create(APRThrustHackDriveMaintainerFacing)

function SetAltitude(Alt)
   DesiredAltitude = Alt
end

function AdjustAltitude(Delta) -- luacheck: ignore 131
   SetAltitude(C:Altitude() + Delta)
end

function SetPitch(Angle) -- luacheck: ignore 131
   DesiredPitch = Angle
end

function SetRoll(Angle) -- luacheck: ignore 131
   DesiredRoll = Angle
end

function APRThreeDoF_Classify(Index, BlockInfo, IsSpinner, Fractions, Infos)
   local LocalForwards = IsSpinner and (BlockInfo.LocalRotation * Vector3.up) or BlockInfo.LocalForwards
   if math.abs(LocalForwards.y) > .001 then
      local CoMOffset = BlockInfo.LocalPositionRelativeToCom
      local UpSign = Sign(LocalForwards.y)
      local Info = {
         Index = Index,
         UpSign = ControlAltitude and (UpSign * Fractions.Altitude) or 0,
         PitchSign = ControlPitch and (Sign(CoMOffset.z) * UpSign * Fractions.Pitch) or 0,
         RollSign = ControlRoll and (Sign(CoMOffset.x) * UpSign * Fractions.Roll) or 0,
      }
      if Info.UpSign ~= 0 or Info.PitchSign ~= 0 or Info.RollSign ~= 0 then
         table.insert(Infos, Info)
      end
   end
end

function APRThreeDoF_ClassifyJets(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= APRThreeDoF_LastPropulsionCount then
      APRThreeDoF_LastPropulsionCount = PropulsionCount
      APRThreeDoF_PropulsionInfos = {}

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         APRThreeDoF_Classify(i, BlockInfo, false, JetFractions, APRThreeDoF_PropulsionInfos)
      end
   end
end

function APRThreeDoF_ClassifySpinners(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= APRThreeDoF_LastSpinnerCount then
      APRThreeDoF_LastSpinnerCount = SpinnerCount
      APRThreeDoF_SpinnerInfos = {}

      for i = 0,SpinnerCount-1 do
         -- Only process dediblades for now
         if I:IsSpinnerDedicatedHelispinner(i) then
            local BlockInfo = I:GetSpinnerInfo(i)
            APRThreeDoF_Classify(i, BlockInfo, true, SpinnerFractions, APRThreeDoF_SpinnerInfos)
         end
      end

      if DediBladesAlwaysUp then
         -- Flip signs on any spinners with negative UpSign
         for _,Info in pairs(APRThreeDoF_SpinnerInfos) do
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

function APRThreeDoF_Update(I)
   local AltitudeCV = ControlAltitude and AltitudePID:Control(DesiredAltitude - C:Altitude()) or 0
   local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - C:Pitch()) or 0
   local RollCV = ControlRoll and RollPID:Control(DesiredRoll - C:Roll()) or 0

   if APRThreeDoF_UsesJets then
      APRThreeDoF_ClassifyJets(I)

      -- Blip upward and downward thrusters
      if not APRThrustHackDriveMaintainerFacing then
         I:RequestThrustControl(4)
         I:RequestThrustControl(5)
      else
         APRThrustHackControl:SetThrottle(I, 1)
      end

      -- And set drive fraction accordingly
      for _,Info in pairs(APRThreeDoF_PropulsionInfos) do
         -- Sum up inputs and constrain
         local Output = AltitudeCV * Info.UpSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign
         Output = math.max(0, math.min(30, Output))
         I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 30)
      end
   end

   if APRThreeDoF_UsesSpinners then
      APRThreeDoF_ClassifySpinners(I)

      -- Set spinner speed
      for _,Info in pairs(APRThreeDoF_SpinnerInfos) do
         -- Sum up inputs and constrain
         local Output = AltitudeCV * Info.UpSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign
         Output = math.max(-30, math.min(30, Output))
         I:SetSpinnerContinuousSpeed(Info.Index, Output)
      end
   end
end

function APRThreeDoF_Disable(I)
   -- Disable drive maintainer, if any
   APRThrustHackControl:SetThrottle(I, 0)
   if APRThreeDoF_UsesSpinners then
      APRThreeDoF_ClassifySpinners(I)
      -- And stop spinners as well
      for _,Info in pairs(APRThreeDoF_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
end
