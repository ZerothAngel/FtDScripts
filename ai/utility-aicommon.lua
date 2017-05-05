--@ commons control planarvector spairs
-- Utility AI module (common)

-- Save original MaxEnemyRange
EscapeRange = Commons.MaxEnemyRange

-- And disable range check
Commons.MaxEnemyRange = math.huge

-- Note: Needs to be unfiltered (by range)
function GetTargets()
   local Targets = {}
   local TargetsById = {}

   for _,Target in ipairs(C:Targets()) do
      table.insert(Targets, Target)
      TargetsById[Target.Id] = Target
   end
   return Targets,TargetsById
end

function GetResourceZones(I, ReferencePosition)
   local ResourceZones = {}
   for _,ResourceZone in ipairs(I.ResourceZones) do
      local Distance = (ResourceZone.Position - ReferencePosition).magnitude
      if Distance < GatherMaxDistance and ResourceZone.Resources.NaturalTotal > 0 then
         local RZInfo = {
            Distance = Distance,
            Position = ResourceZone.Position,
            Radius = ResourceZone.Radius,
         }
         table.insert(ResourceZones, RZInfo)
      end
   end
   return ResourceZones
end

LastSeenTargets = {}
CollectorDestinations = {}
CollectorNeedsSort = false

function SortDestinations()
   local SelectedIndex,ClosestDistance = nil,math.huge
   for index,Destination in pairs(CollectorDestinations) do
      local Offset,_ = PlanarVector(C:CoM(), Destination)
      local Distance = Offset.sqrMagnitude
      if Distance < ClosestDistance then
         SelectedIndex = index
         ClosestDistance = Distance
      end
   end

   if SelectedIndex then
      -- Remove from list
      local Destination = table.remove(CollectorDestinations, SelectedIndex)
      -- And insert at top
      table.insert(CollectorDestinations, 1, Destination)
   end

   CollectorNeedsSort = false
end

function PickDestination(ReferencePosition)
   while #CollectorDestinations > 0 do
      local Destination = CollectorDestinations[1]
      local Offset,_ = PlanarVector(ReferencePosition, Destination)
      if Offset.magnitude < CollectMaxDistance then
         return Destination
      else
         -- Too far, remove it and check next
         table.remove(CollectorDestinations, 1)
         SortDestinations()
      end
   end

   return nil
end

function UtilityAI_Reset(_)
   CollectorDestinations = {}
end

function UtilityAI_Main(I)
   local Targets,TargetsById = GetTargets()

   if IsCollector then
      -- Check if targets are still around
      for _,Target in pairs(LastSeenTargets) do
         if not TargetsById[Target.Id] then
            -- Target gone, make note of its last position
            table.insert(CollectorDestinations, Target.Position)
            CollectorNeedsSort = true
         end
      end
      -- Current targets become last seen targets
      LastSeenTargets = Targets
   end

   -- Escape mode only when enemies in range
   local EnemiesInRange = false
   for _,Target in pairs(Targets) do
      if Target.Range <= EscapeRange then
         EnemiesInRange = true
         break
      end
   end

   if EnemiesInRange then
      -- Sum up the all enemy direction vectors
      local RunAway,Count = Vector3.zero,0
      for _,Target in pairs(Targets) do
         local Distance = PlanarVector(C:CoM(), Target.Position).magnitude
         if Distance < RunAwayDistance then
            RunAway = RunAway + Target.Offset / Target.Range
            Count = Count + 1
         end
      end

      UtilityAI_RunAway(I, Count > 0 and RunAway or nil)

      return true
   else
      if IsCollector and CollectorNeedsSort then
         SortDestinations()
      end

      local FlagshipPosition = I.Fleet.Flagship.CenterOfMass
      local HasRoom= I.Resources.NaturalTotal < (FreeStorageThreshold * I.Resources.NaturalMax)

      -- Collector logic
      local Collecting = false
      if IsCollector then
         local Destination = PickDestination(FlagshipPosition)
         while Destination and HasRoom do
            local Target,_ = PlanarVector(C:CoM(), Destination)
            local Distance = Target.magnitude
            if Distance >= CollectMinDistance then
               UtilityAI_MoveToCollect(I, Destination)
               Collecting = true
               -- One at a time
               break
            else
               -- Done with this one
               table.remove(CollectorDestinations, 1)
               SortDestinations()
               Destination = PickDestination(FlagshipPosition)
            end
         end
      end

      -- Gatherer logic
      local Gathering = false
      if IsGatherer and not Collecting and HasRoom then
         local ResourceZones = GetResourceZones(I, FlagshipPosition)
         for _,RZInfo in spairs(ResourceZones, function(t,a,b) return t[a].Distance < t[b].Distance end) do -- luacheck: ignore 512
            UtilityAI_MoveToGather(I, RZInfo)
            Gathering = true
            -- Only care about the first one
            break
         end
      end

      return Collecting or Gathering
   end
end

function UtilityAI_Update(I)
   V.Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if not UtilityAI_Main(I) then
         UtilityAI_FormationMove(I)
      end
   else
      UtilityAI_Reset()
      UtilityAI_FormationMove(I)
   end
end
