--! stabilizer
--@ api getselfinfo pid
-- Stabilizer module
RollPID = PID.create(RollPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)

LastPropulsionCount = 0
PropulsionInfos = {}

-- TODO Refactor. Most of the following ripped from subcontrol.

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

      -- Keep track of max negative and positive offsets
      -- Note: The numbers stored are always non-negative.
      -- Sign of offset is tracked using the table index (-1 or 1)
      local XMax = {}
      XMax[-1] = 0
      XMax[1] = 0

      local ZMax = {}
      ZMax[-1] = 0
      ZMax[1] = 0

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         -- Determine sign and location of propulsion
         local LocalSign = GetPropulsionSign(BlockInfo)
         if LocalSign ~= 0 then
            -- Only care about propulsion pointing up or down
            local CoMOffset = BlockInfo.LocalPositionRelativeToCom
            local CoMOffsetX = CoMOffset.x
            local CoMOffsetZ = CoMOffset.z
            local RollScale = Mathf.Sign(CoMOffsetX)
            local PitchScale = Mathf.Sign(CoMOffsetZ)
            local Info = {
               Index = i,
               LocalSign = LocalSign,
               -- Default scale is 1, -1, or 0 depending on sign of offset
               -- NB Mathf.Sign returns 1 for 0...
               RollScale = CoMOffsetX ~= 0 and RollScale or 0,
               PitchScale = CoMOffsetZ ~= 0 and PitchScale or 0,
               CoMOffsetX = CoMOffsetX,
               CoMOffsetZ = CoMOffsetZ,
            }
            table.insert(PropulsionInfos, Info)

            -- Also keep track of furthest propulsion on each axis
            CoMOffsetX = math.abs(CoMOffsetX)
            XMax[RollScale] = math.max(XMax[RollScale], CoMOffsetX)

            CoMOffsetZ = math.abs(CoMOffsetZ)
            ZMax[PitchScale] = math.max(ZMax[PitchScale], CoMOffsetZ)
         end
      end

      if ScaleByCoMOffset then
         -- Now go back and pre-calculate scale
         for _,Info in pairs(PropulsionInfos) do
            local CoMOffsetX = Info.CoMOffsetX
            if CoMOffsetX ~= 0 then
               Info.RollScale = XMax[Info.RollScale] / CoMOffsetX
            end

            local CoMOffsetZ = Info.CoMOffsetZ
            if CoMOffsetZ ~= 0 then
               Info.PitchScale = ZMax[Info.PitchScale] / CoMOffsetZ
            end
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
