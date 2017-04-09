--@ commons manualcontroller evasion terraincheck
-- Depth Control module
ManualDepthController = ManualController.create(ManualDepthDriveMaintainerFacing)

-- Note: Aside from Offset, all should be absolute altitudes, i.e. -depth
DepthControl_Desired = 0
DepthControl_Offset = 0
DepthControl_Min = 0
DepthControl_Max = 0

function Depth_Control(I)
   DepthControl_Offset = 0
   DepthControl_Min = -HardMaxDepth
   DepthControl_Max = -HardMinDepth

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
         end
         if ManualEvasion and C:FirstTarget() then
            DepthControl_Offset = CalculateEvasion(DepthEvasion)
         end
      else
         -- Use configured depths
         if C:FirstTarget() then
            DesiredDepth,Absolute = DesiredDepthCombat.Depth,DesiredDepthCombat.Absolute
            DepthControl_Offset = CalculateEvasion(DepthEvasion)
         else
            DesiredDepth,Absolute = DesiredDepthIdle.Depth,DesiredDepthIdle.Absolute
         end
      end

      if Absolute then
         DesiredDepth = -DesiredDepth
      else
         -- Look ahead at terrain
         local TerrainHeight = GetTerrainHeight(I, C:Velocity(), -500, -TerrainMinDepth)
         -- Set new absolute minimum
         DepthControl_Min = math.max(DepthControl_Min, TerrainHeight)
         -- And offset desired depth (actually desired elevation) by terrain
         DesiredDepth = DesiredDepth + TerrainHeight
         -- And constrain by relative limits
         DesiredDepth = math.max(-TerrainMaxDepth, math.min(-TerrainMinDepth, DesiredDepth))
      end

      DepthControl_Desired = DesiredDepth
   end
end

function Depth_Apply(_, HighPriorityOffset, NoOffset)
   -- Determine depth based on presence of HighPriorityOffset
   local NewAltitude
   if DepthDodging and HighPriorityOffset then
      NewAltitude = C:Altitude() + HighPriorityOffset
   else
      NewAltitude = DepthControl_Desired + (NoOffset and 0 or DepthControl_Offset)
   end
   -- Constrain and set
   SetAltitude(math.max(DepthControl_Min, math.min(DepthControl_Max, NewAltitude)))
end
