--! subcontrol
--@ terraincheck api debug getselfinfo getvectorangle gettargetpositioninfo
--@ pid firstrun periodic
-- Hydrofoil submarine control module
RollPID = PID.create(RollPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)
DepthPID = PID.create(DepthPIDConfig, -1, 1)

DesiredDepth = 0

LastHydrofoilCount = 0
HydrofoilInfos = {}

LastDriveMaintainerCount = 0
ManualDepthDriveMaintainer = nil
ManualDesiredDepth = 0

function GetHydrofoilSign(BlockInfo)
   -- Check if hydrofoil's forward vector lies on Z-axis and up vector lies on Y-axis.
   local DotZ = BlockInfo.LocalForwards.z
   local DotY = (BlockInfo.LocalRotation * Vector3.up).y
   if math.abs(DotZ) > 0.001 and math.abs(DotY) > 0.001 then
      -- Facing forwards or backwards on XZ plane, return appropriate sign
      return Mathf.Sign(DotZ) * Mathf.Sign(DotY)
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
      XMax[1] = 0

      local ZMax = {}
      ZMax[-1] = 0
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
   local __func__ = "SetHydrofoilAngles"

   ClassifyHydrofoils(I)

   -- In case vehicle is going in reverse...
   local VehicleSign = Mathf.Sign(I:GetForwardsVelocityMagnitude())

   for _,Info in pairs(HydrofoilInfos) do
      -- Sum up inputs and constrain
      local Output = (RollCV * Info.RollScale + PitchCV * Info.PitchScale + DepthCV) * 45
      Output = math.max(-45, math.min(45, Output))

      if Debugging then Debug(I, __func__, "#%d Total = %f", Info.Index, Total) end
      I:Component_SetFloatLogic(HYDROFOIL, Info.Index, VehicleSign * Info.LocalSign * Output)
   end
end

function GetManualDesiredDepth(I)
   local DriveMaintainerCount = I:Component_GetCount(DRIVEMAINTAINER)
   if DriveMaintainerCount ~= LastDriveMaintainerCount then
      -- Clear cached index
      ManualDepthDriveMaintainer = nil
      LastDriveMaintainerCount = DriveMaintainerCount
   end

   if not ManualDepthDriveMaintainer then
      -- Look for the first one facing the direction we want
      for i = 0,DriveMaintainerCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(DRIVEMAINTAINER, i)
         if Vector3.Dot(BlockInfo.LocalForwards, ManualDepthDriveMaintainerFacing) > 0.001 then
            ManualDepthDriveMaintainer = i
            break
         end
      end
   
      if not ManualDepthDriveMaintainer then
         -- Still don't have one, just return last setting
         return ManualDesiredDepth
      end
   end

   return I:Component_GetFloatLogic(DRIVEMAINTAINER, ManualDepthDriveMaintainer)
end

function SubControl_Update(I)
   if ControlDepth then
      local Absolute
      if not ManualDepthDriveMaintainerFacing then
         -- Use configured depths
         if GetTargetPositionInfo(I) then
            DesiredDepth,Absolute = DesiredDepthCombat.Depth,DesiredDepthCombat.Absolute
         else
            DesiredDepth,Absolute = DesiredDepthIdle.Depth,DesiredDepthIdle.Absolute
         end
      else
         -- Manual depth control
         ManualDesiredDepth = GetManualDesiredDepth(I)
         if ManualDesiredDepth > 0 then
            -- Relative
            DesiredDepth,Absolute = (500 - ManualDesiredDepth*500),false
         else
            -- Absolute
            DesiredDepth,Absolute = -ManualDesiredDepth*500,true
         end
      end

      if Absolute then
         DesiredDepth = -DesiredDepth
      else
         -- Look ahead at terrain
         local Velocity = I:GetVelocityVector()
         DesiredDepth = DesiredDepth + GetTerrainHeight(I, Velocity)
         -- No higher than MinDepth
         DesiredDepth = math.min(DesiredDepth, -MinDepth)
      end
   end
end

SubControl = Periodic.create(UpdateRate, SubControl_Update)

function Update(I)
   if FirstRun then FirstRun(I) end

   if not I:IsDocked() and I.AIMode ~= "off" then
      GetSelfInfo(I)

      SubControl:Tick(I)

      -- This stuff needs to happen every update, regardless of UpdateRate
      local RollCV = ControlRoll and RollPID:Control(-Roll) or 0
      local PitchCV = ControlPitch and PitchPID:Control(-Pitch) or 0
      local DepthCV = ControlDepth and DepthPID:Control(DesiredDepth - Altitude) or 0

      SetHydrofoilAngles(I, RollCV, PitchCV, DepthCV)
   end
end
