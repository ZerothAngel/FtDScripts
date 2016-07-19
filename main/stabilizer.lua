--! stabilizer
--@ api sign getselfinfo pid
-- Stabilizer module
RollPID = PID.create(RollPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)

LastPropulsionCount = 0
PropulsionInfos = {}

-- TODO Refactor. Most of the following ripped from subcontrol.

-- Returns 1, -1, or 0 depending on whether or not it provides
-- thrust along the Y axis.
function GetPropulsionSign(BlockInfo)
   local DotY = BlockInfo.LocalForwards.y
   if math.abs(DotY) > 0.001 then
      return Mathf.Sign(DotY)
   else
      return 0
   end
end

function ClassifyPropulsion(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= LastPropulsionCount then
      -- Something got damaged or repaired, clear the cache
      PropulsionInfos = {}
      LastPropuslionCount = PropulsionCount

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         -- Determine sign and location of propulsion
         local LocalSign = GetPropulsionSign(BlockInfo)
         if LocalSign ~= 0 then
            -- Only care about propulsion pointing up or down
            local CoMOffset = BlockInfo.LocalPositionRelativeToCom
            local Info = {
               Index = i,
               LocalSign = LocalSign,
               RollScale = Sign(CoMOffset.x),
               PitchScale = Sign(CoMOffset.z),
            }
            table.insert(PropulsionInfos, Info)
         end
      end
   end
end

function SetPropulsionThrust(I, RollCV, PitchCV)
   ClassifyPropulsion(I)

   -- Blip upward and downward thrusters
   I:RequestThrustControl(4)
   I:RequestThrustControl(5)

   -- And set drive fraction accordingly
   for _,Info in pairs(PropulsionInfos) do
      -- Sum up inputs and constrain
      local Output = RollCV * Info.RollScale + PitchCV * Info.PitchScale
      Output = math.max(0, math.min(1, Output))
      -- If pointing the other way, set output to 0
      if (Output * Info.LocalSign) < 0 then
         Output = 0
      end
      I:Component_SetFloatLogic(PROPULSION, Info.Index, Output)
   end
end

function Update(I)
   if not I:IsDocked() and I.AIMode ~= "off" then
      GetSelfInfo(I)

      local RollCV = ControlRoll and RollPID:Control(-Roll) or 0
      local PitchCV = ControlPitch and PitchPID:Control(-Pitch) or 0

      SetPropulsionThrust(I, RollCV, PitchCV)
   end
end
