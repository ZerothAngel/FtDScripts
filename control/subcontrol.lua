--@ commons componenttypes pid sign
-- Hydrofoil submarine control module
RollPID = PID.create(RollPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)
DepthPID = PID.create(DepthPIDConfig, -1, 1)

DesiredAltitude = 0
DesiredPitch = 0
DesiredRoll = 0

LastHydrofoilCount = 0
HydrofoilInfos = {}

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

function GetHydrofoilSign(BlockInfo)
   -- Check if hydrofoil's forward vector lies on Z-axis and up vector lies on Y-axis.
   local DotZ = BlockInfo.LocalForwards.z
   local DotY = (BlockInfo.LocalRotation * Vector3.up).y
   if math.abs(DotZ) > 0.001 and math.abs(DotY) > 0.001 then
      -- Facing forwards or backwards on XZ plane, return appropriate sign
      return Sign(DotZ) * Sign(DotY)
   else
      -- Some other orientation
      return 0
   end
end

function ClassifyHydrofoils(I)
   local HydrofoilCount = I:Component_GetCount(HYDROFOIL)
   if HydrofoilCount ~= LastHydrofoilCount then
      -- Something got damaged or repaired, clear the cache
      HydrofoilInfos = {}
      LastHydrofoilCount = HydrofoilCount

      -- Keep track of max negative and positive offsets
      -- Note: The numbers stored are always non-negative.
      -- Sign of offset is tracked using the table index (-1 or 1)
      local XMax = {}
      XMax[-1] = 0
      XMax[0] = 0
      XMax[1] = 0

      local ZMax = {}
      ZMax[-1] = 0
      ZMax[0] = 0
      ZMax[1] = 0

      -- And repopulate it
      for i = 0,HydrofoilCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(HYDROFOIL, i)
         -- Determine sign and location of hydrofoil
         local LocalSign = GetHydrofoilSign(BlockInfo)
         if LocalSign ~= 0 then
            -- Only care about hydrofoils oriented forwards/backwards on XZ
            -- plane
            local CoMOffset = BlockInfo.LocalPositionRelativeToCom
            local CoMOffsetX = CoMOffset.x
            local CoMOffsetZ = CoMOffset.z
            local RollScale = Sign(CoMOffsetX)
            local PitchScale = Sign(CoMOffsetZ)
            local Info = {
               Index = i,
               LocalSign = LocalSign,
               -- Default scale is 1, -1, or 0 depending on sign of offset
               RollScale = RollScale,
               PitchScale = PitchScale,
               CoMOffsetX = CoMOffsetX,
               CoMOffsetZ = CoMOffsetZ,
            }
            table.insert(HydrofoilInfos, Info)

            -- Also keep track of furthest hydrofoil on each axis
            CoMOffsetX = math.abs(CoMOffsetX)
            XMax[RollScale] = math.max(XMax[RollScale], CoMOffsetX)

            CoMOffsetZ = math.abs(CoMOffsetZ)
            ZMax[PitchScale] = math.max(ZMax[PitchScale], CoMOffsetZ)
         end
      end

      if ScaleByCoMOffset then
         -- Now go back and pre-calculate scale
         for _,Info in pairs(HydrofoilInfos) do
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

function SetHydrofoilAngles(I, RollCV, PitchCV, DepthCV)
   ClassifyHydrofoils(I)

   -- In case vehicle is going in reverse...
   local VehicleSign = Sign(C:ForwardSpeed(), 1)

   for _,Info in pairs(HydrofoilInfos) do
      -- Sum up inputs and constrain
      local Output = (RollCV * Info.RollScale + PitchCV * Info.PitchScale + DepthCV) * 45
      Output = math.max(-45, math.min(45, Output))

      I:Component_SetFloatLogic(HYDROFOIL, Info.Index, VehicleSign * Info.LocalSign * Output)
   end
end

function SubControl_Update(I)
   local RollCV = ControlRoll and RollPID:Control(DesiredRoll - C:Roll()) or 0
   local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - C:Pitch()) or 0
   local DepthCV = ControlDepth and DepthPID:Control((DesiredAltitude - C:Altitude()) * C:UpVector().y) or 0

   SetHydrofoilAngles(I, RollCV, PitchCV, DepthCV)
end
