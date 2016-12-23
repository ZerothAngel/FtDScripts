--@ commons manualcontroller terraincheck
-- Depth Control module
ManualDepthController = ManualController.create(ManualDepthDriveMaintainerFacing)

DesiredControlAltitude = 0

function Depth_Control(I)
   if ControlDepth then
      local DesiredDepth,Absolute
      if ManualDepthDriveMaintainerFacing and ManualDepthWhen[I.AIMode] then
         -- Manual depth control
         local ManualDesiredDepth = ManualDepthController:GetReading(I)
         if ManualDesiredDepth > 0 then
            -- Relative
            DesiredDepth,Absolute = (500 - ManualDesiredDepth*500),false
         else
            -- Absolute
            DesiredDepth,Absolute = -ManualDesiredDepth*500,true
            DesiredDepth = math.max(DesiredDepth, MinManualDepth)
         end
      else
         -- Use configured depths
         if C:FirstTarget() then
            DesiredDepth,Absolute = DesiredDepthCombat.Depth,DesiredDepthCombat.Absolute
         else
            DesiredDepth,Absolute = DesiredDepthIdle.Depth,DesiredDepthIdle.Absolute
         end
      end

      if Absolute then
         DesiredDepth = -DesiredDepth
      else
         -- Look ahead at terrain
         local Velocity = I:GetVelocityVector()
         DesiredDepth = DesiredDepth + GetTerrainHeight(I, Velocity, -(MaxDepth + DesiredDepth), -MinDepth)
         -- No higher than MinDepth
         DesiredDepth = math.min(DesiredDepth, -MinDepth)
      end

      DesiredControlAltitude = DesiredDepth
   end
end
