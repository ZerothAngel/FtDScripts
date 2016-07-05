--! depth
--@ terraincheck commons getvectorangle gettargetpositioninfo pid periodic
-- Hydrofoil sea depth module
HydrofoilPID = PID.create(HydrofoilPIDValues[1], HydrofoilPIDValues[2], HydrofoilPIDValues[3], -45, 45, UpdateRate)

FirstRun = nil

function FirstRun(I)
   FirstRun = nil

   TerrainCheckFirstRun(I)
end

function Depth_Update(I)
   local __func__ = "Update"

   if FirstRun then FirstRun(I) end

   if I.AIMode ~= "off" then
      GetSelfInfo(I)

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

      if Debugging then Debug(I, __func__, "DesiredDepth %f", DesiredDepth) end

      local CV = HydrofoilPID:Control(DesiredDepth - Altitude)

      I:Component_SetFloatLogicAll(HYDROFOIL, Mathf.Sign(I:GetForwardsVelocityMagnitude()) * CV)
   end
end

Depth = Periodic.create(UpdateRate, Depth_Update)

function Update(I)
   Depth:Tick(I)
end
