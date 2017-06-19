--@ commonstargets commons componenttypes planarvector
-- Dock manager module
DockManager_LastDockCount = 0
DockManager_DockInfos = {}

DockManager_FirstTimeEnemySeen = nil
DockManager_LastTimeEnemySeen = -DockManagerConfig.RecallDelay

-- Pre-square ThreatDistance
DockManagerConfig.ThreatDistance = DockManagerConfig.ThreatDistance * DockManagerConfig.ThreatDistance

function DockManager_Classify(I)
   local DockCount = I:Component_GetCount(TRACTORBEAM)
   if DockCount ~= DockManager_LastDockCount then
      DockManager_LastDockCount = DockCount
      DockManager_DockInfos = {}

      local ReleaseDelay = DockManagerConfig.ReleaseDelay

      for i=0,DockCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(TRACTORBEAM, i)
         local Info = {
            Index = i,
            --# Negated so it goes front-to-back
            RelativeOrder = -BlockInfo.LocalPositionRelativeToCom.z,
            ReleaseDelay = ReleaseDelay,
         }
         table.insert(DockManager_DockInfos, Info)
      end

      local SequentialDelay = DockManagerConfig.SequentialDelay
      if SequentialDelay then
         -- Sort and add delay
         table.sort(DockManager_DockInfos, function (a,b) return a.RelativeOrder < b.RelativeOrder end)
         for i,Info in ipairs(DockManager_DockInfos) do
            Info.ReleaseDelay = Info.ReleaseDelay + (i-1) * SequentialDelay
         end
      end
   end
end

function DockManager_Update(I)
   DockManager_Classify(I)

   -- Shortcut: don't recall while there are enemies in range (determined
   -- by Commons.MaxEnemyRange)
   local ThreatsDetected = DockManager_FirstTimeEnemySeen and C:FirstTarget()
   if not ThreatsDetected then
      -- Scan for enemies within ThreatDistance
      local ThreatDistance = DockManagerConfig.ThreatDistance
      for _,Target in ipairs(C:Targets()) do
         local Offset,_ = PlanarVector(C:CoM(), Target.Position)
         if Offset.sqrMagnitude <= ThreatDistance then
            ThreatsDetected = true
            break
         end
      end
   end

   local Now = C:Now()
   if ThreatsDetected then
      DockManager_LastTimeEnemySeen = Now

      if not DockManager_FirstTimeEnemySeen then
         DockManager_FirstTimeEnemySeen = Now
      end

      for _,Info in pairs(DockManager_DockInfos) do
         if DockManager_FirstTimeEnemySeen + Info.ReleaseDelay <= Now then
            I:Component_SetBoolLogic(TRACTORBEAM, Info.Index, false)
         end
      end
   elseif DockManager_LastTimeEnemySeen + DockManagerConfig.RecallDelay <= Now then
      --# They all recall at the same time... for now
      for _,Info in pairs(DockManager_DockInfos) do
         I:Component_SetBoolLogic(TRACTORBEAM, Info.Index, true)
      end

      -- Only reset first seen timer once recall triggers
      DockManager_FirstTimeEnemySeen = nil
   end
end
