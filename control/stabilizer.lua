--@ componenttypes sign pid thrusthack
-- Stabilizer module
RollPID = PID.create(RollPIDConfig, -10, 10)
PitchPID = PID.create(PitchPIDConfig, -10, 10)

LastPropulsionCount = 0
PropulsionInfos = {}

DesiredPitch = 0
DesiredRoll = 0

ThrustHackControl = ThrustHack.create(ThrustHackDriveMaintainerFacing)

function SetPitch(Angle) -- luacheck: ignore 131
   DesiredPitch = Angle
end

function SetRoll(Angle) -- luacheck: ignore 131
   DesiredRoll = Angle
end

-- Determine sign and location of propulsion elements
function ClassifyPropulsion(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= LastPropulsionCount then
      -- Something got damaged or repaired, clear the cache
      PropulsionInfos = {}
      LastPropulsionCount = PropulsionCount

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         local LocalForwards = BlockInfo.LocalForwards
         if math.abs(LocalForwards.y) > .001 then
            -- Only care about propulsion pointing up or down
            local CoMOffset = BlockInfo.LocalPositionRelativeToCom
            local UpSign = Sign(LocalForwards.y)
            local Info = {
               Index = i,
               RollSign = ControlRoll and (Sign(CoMOffset.x) * UpSign) or 0,
               PitchSign = ControlPitch and (Sign(CoMOffset.z) * UpSign) or 0,
            }
            table.insert(PropulsionInfos, Info)
         end
      end
   end
end

-- Controls upward/downward facing propulsion elements to stabilize roll/pitch
-- Should be called every update.
function Stabilizer_Update(I)
   if ControlRoll or ControlPitch then
      local RollCV = ControlRoll and RollPID:Control(DesiredRoll - C:Roll()) or 0
      local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - C:Pitch()) or 0

      ClassifyPropulsion(I)

      -- Blip upward and downward thrusters
      if not ThrustHackDriveMaintainerFacing then
         I:RequestThrustControl(4)
         I:RequestThrustControl(5)
      else
         ThrustHackControl:SetThrottle(I, 1)
      end

      -- And set drive fraction accordingly
      for _,Info in pairs(PropulsionInfos) do
         -- Sum up inputs and constrain
         local Output = RollCV * Info.RollSign + PitchCV * Info.PitchSign
         Output = math.max(0, math.min(10, Output))
         I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 10)
      end
   end
end

function Stabilizer_Disable(I)
   -- Disable drive maintainer, if any
   ThrustHackControl:SetThrottle(I, 0)
end
