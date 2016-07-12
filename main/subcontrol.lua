--! subcontrol
--@ terraincheck commons getvectorangle gettargetpositioninfo pid periodic
-- Hydrofoil submarine control module
RollPID = PID.create(RollPIDValues[1], RollPIDValues[2], RollPIDValues[3], -1, 1, UpdateRate)
PitchPID = PID.create(PitchPIDValues[1], PitchPIDValues[2], PitchPIDValues[3], -1, 1, UpdateRate)
DepthPID = PID.create(DepthPIDValues[1], DepthPIDValues[2], DepthPIDValues[3], -1, 1, UpdateRate)

LastHydrofoilCount = 0
HydrofoilInfos = {}

function GetHydrofoilSign(BlockInfo)
   -- Check if hydrofoil's forward vector lies on Z-axis and up vector lies on Y-axis.
   -- Probably don't need dot product (can just check signs), but just to be safe...
   local DotZ = Vector3.Dot(BlockInfo.LocalForwards, Vector3.forward)
   local DotY = Vector3.Dot(BlockInfo.LocalRotation * Vector3.up, Vector3.up)
   if math.abs(DotZ) > 0.001 and math.abs(DotY) > 0.001 then -- It's never exactly zero
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

function SubControl_Update(I)
   if not I:IsDocked() and I.AIMode ~= "off" then
      GetSelfInfo(I)

      local DepthCV = 0
      if ControlDepth then
         local DesiredDepth,Absolute
         if GetTargetPositionInfo(I) then
            DesiredDepth,Absolute = DesiredDepthCombat[1],DesiredDepthCombat[2]
         else
            DesiredDepth,Absolute = DesiredDepthIdle[1],DesiredDepthIdle[2]
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
