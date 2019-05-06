--@ commonstargets commons control drivemaintainer evasion terraincheck sign clamp
-- Depth Control module
ManualDepthController = DriveMaintainer.new(ManualDepthDriveMaintainerName)

-- Note: Aside from Offset, all should be absolute altitudes, i.e. -depth
DepthControl_Desired = 0
DepthControl_Offset = 0
DepthControl_Min = 0
DepthControl_Max = 0

DepthControl_LastDodge = nil

function Depth_Control(I)
   DepthControl_Offset = 0
   DepthControl_Min = -HardMaxDepth
   DepthControl_Max = -HardMinDepth

   local DesiredDepth,Absolute
   if ManualDepthDriveMaintainerName and ManualDepthWhen[C:MovementMode()] then
      -- Manual depth control
      local ManualDesiredDepth = ManualDepthController:GetThrottle(I)
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
      -- And constrain by relative limits
      DesiredDepth = Clamp(DesiredDepth + TerrainHeight, -TerrainMaxDepth, -TerrainMinDepth)
   end

   DepthControl_Desired = DesiredDepth
end

function Depth_Apply(_, HighPriorityOffset, NoOffset)
   -- Determine depth based on presence of HighPriorityOffset
   local NewAltitude
   if DepthDodgeMode > 0 and HighPriorityOffset then
      if DepthDodgeMode == 2 then
         -- Most leeway
         if DepthControl_LastDodge then
            -- Try to keep going in the same direction
            if Sign(HighPriorityOffset) == DepthControl_LastDodge[1] then
               NewAltitude = C:Altitude() + DepthControl_LastDodge[2] * math.abs(HighPriorityOffset)
            else
               -- But reset if the AI changes direction
               DepthControl_LastDodge = nil
            end
         end
         if not DepthControl_LastDodge then
            local Above = math.max(0, DepthControl_Max - C:Altitude())
            local Below = math.max(0, C:Altitude() - DepthControl_Min)
            if Below > Above then
               NewAltitude = C:Altitude() - math.abs(HighPriorityOffset)
               DepthControl_LastDodge = { Sign(HighPriorityOffset), -1 }
            else
               NewAltitude = C:Altitude() + math.abs(HighPriorityOffset)
               DepthControl_LastDodge = { Sign(HighPriorityOffset), 1 }
            end
         end
      elseif DepthDodgeMode == 3 then
         -- Always upwards
         NewAltitude = C:Altitude() + math.abs(HighPriorityOffset)
      elseif DepthDodgeMode == 4 then
         -- Always downwards
         NewAltitude = C:Altitude() - math.abs(HighPriorityOffset)
      else
         -- As recommended
         NewAltitude = C:Altitude() + HighPriorityOffset
      end
   else
      NewAltitude = DepthControl_Desired + (NoOffset and 0 or DepthControl_Offset)
      DepthControl_LastDodge = nil
   end
   -- Constrain and set
   V.SetAltitude(Clamp(NewAltitude, DepthControl_Min, DepthControl_Max))
end
