--! subcontrol
--@ terraincheck commons getvectorangle gettargetpositioninfo pid periodic
-- Hydrofoil submarine control module
RollPID = PID.create(RollPIDConfig, -1, 1, UpdateRate)
PitchPID = PID.create(PitchPIDConfig, -1, 1, UpdateRate)
DepthPID = PID.create(DepthPIDConfig, -1, 1, UpdateRate)

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

function SetHydrofoilAngles(I, RollCV, PitchCV, DepthCV)
   local __func__ = "SetHydrofoilAngles"

   local VehicleSign = Mathf.Sign(I:GetForwardsVelocityMagnitude())
   local Eps = Mathf.Epsilon

   local HydrofoilCount = I:Component_GetCount(HYDROFOIL)
   if HydrofoilCount ~= LastHydrofoilCount then
      -- Something got damaged or repaired, clear the cache
      HydrofoilInfos = {}
      LastHydrofoilCount = HydrofoilCount
   end

   for i = 0,HydrofoilCount-1 do
      local Info = HydrofoilInfos[i]
      if not Info then
         local BlockInfo = I:Component_GetBlockInfo(HYDROFOIL, i)
         -- Determine location and sign of hydrofoil
         Info = {
            LocalSign = GetHydrofoilSign(BlockInfo),
            CoMOffset = BlockInfo.LocalPositionRelativeToCom
         }
         -- Cache it
         HydrofoilInfos[i] = Info
      end

      local LocalSign,CoMOffset = Info.LocalSign,Info.CoMOffset
      if LocalSign ~= 0 then
         local Roll,Pitch,Depth = 0,0,0
         -- Try without scaling w.r.t. offset first
         local CoMX,CoMZ = CoMOffset.x,CoMOffset.z
         if math.abs(CoMX) > Eps then
            Roll = Mathf.Sign(CoMX) * RollCV
         end
         if math.abs(CoMZ) > Eps then
            Pitch = Mathf.Sign(CoMZ) * PitchCV
         end
         Depth = DepthCV

         -- Hmm, normalize?
         local Total = (Roll + Pitch + Depth) * 45
         Total = math.max(-45, math.min(45, Total))

         if Debugging then Debug(I, __func__, "#%d Total = %f", i, Total) end
         I:Component_SetFloatLogic(HYDROFOIL, i, VehicleSign * LocalSign * Total)
      end
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
   if not I:IsDocked() and I.AIMode ~= "off" then
      GetSelfInfo(I)

      local DepthCV = 0
      if ControlDepth then
         local DesiredDepth,Absolute
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
            -- First check CoM's height
            local Height = I:GetTerrainAltitudeForPosition(CoM)
            -- Now check look-ahead values
            local Velocity = I:GetVelocityVector()
            Velocity.y = 0
            local Speed = Velocity.magnitude
            local VelocityAngle = GetVectorAngle(Velocity)
            Height = math.max(Height, GetTerrainHeight(I, VelocityAngle, Speed))
            DesiredDepth = DesiredDepth + Height
            -- No higher than sea level
            DesiredDepth = math.min(DesiredDepth, -MinDepth)
         end

         DepthCV = DepthPID:Control(DesiredDepth - Altitude)
      end

      local RollCV = ControlRoll and RollPID:Control(-Roll) or 0
      local PitchCV = ControlPitch and PitchPID:Control(-Pitch) or 0

      SetHydrofoilAngles(I, RollCV, PitchCV, DepthCV)
   end
end

SubControl = Periodic.create(UpdateRate, SubControl_Update)

function Update(I)
   SubControl:Tick(I)
end
