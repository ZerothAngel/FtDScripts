--@ planarvector getbearingtopoint evasion
--@ spairs avoidance
-- Utility AI module
function GetTargets(I)
   local Targets = {}
   local TargetsById = {}
   for i = 0,I:GetNumberOfTargets(0)-1 do
      local TargetInfo = I:GetTargetInfo(0, i)
      if TargetInfo.Valid and TargetInfo.Protected then
         local Id = TargetInfo.Id
         Target = {
            Id = Id,
            Position = TargetInfo.Position,
         }
         table.insert(Targets, Target)
         TargetsById[Id] = Target
      end
   end
   return Targets, TargetsById
end

function GetResourceZones(I, ReferencePosition)
   local ResourceZones = {}
   for i = 1,#I.ResourceZones do
      local ResourceZone = I.ResourceZones[i]
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
      local Offset,_ = PlanarVector(CoM, Destination)
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

function UtilityAI_Update(I)
   Control_Reset()

   local Drive = nil

   local Targets,TargetsById = GetTargets(I)
   if #Targets > 0 then
      -- Sum up the inverse of all enemy vectors
      local RunAway,Count = Vector3.zero,0
      for _,Target in pairs(Targets) do
         local Offset,_ = PlanarVector(CoM, Target.Position)
         local Distance = Offset.magnitude
         if Distance < RunAwayDistance then
            RunAway = RunAway + Offset / Distance
            Count = Count + 1
         end
      end
      if Count > 0 then
         -- And head in the opposite direction
         local Bearing = GetBearingToPoint(CoM - RunAway)
         Bearing = CalculateEvasion(RunAwayEvasion, Bearing)
         AdjustHeading(Avoidance(I, Bearing))
         Drive = RunAwayDrive
      else
         Drive = 0
      end

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
   else
      if IsCollector then
         -- Remaining last seen targets also become destinations
         for _,Target in pairs(LastSeenTargets) do
            table.insert(CollectorDestinations, Target.Position)
            CollectorNeedsSort = true
         end
         LastSeenTargets = {}

         if CollectorNeedsSort then
            SortDestinations()
         end
      end

      local FlagshipPosition = I.Fleet.Flagship.CenterOfMass
      local StorageMax = FreeStorageThreshold * I.Resources.NaturalMax

      -- Collector logic
      local Collecting = false
      local Destination = PickDestination(FlagshipPosition)
      if Destination and I.Resources.NaturalTotal < StorageMax then
         local Target,_ = PlanarVector(CoM, Destination)
         local Distance = Target.magnitude
         if Distance >= CollectMinDistance then
            local Bearing = GetBearingToPoint(Destination)
            AdjustHeading(Avoidance(I, Bearing))
            Drive = CollectDrive
            Collecting = true
         else
            -- Done with this one
            table.remove(CollectorDestinations, 1)
            SortDestinations()
         end
      end

      -- Gatherer logic
      local Gathering = false
      if IsGatherer and not Collecting and I.Resources.NaturalTotal < StorageMax then
         local ResourceZones = GetResourceZones(I, FlagshipPosition)
         for _,RZInfo in spairs(ResourceZones, function(t,a,b) return t[a].Distance < t[b].Distance end) do
            local Target,_ = PlanarVector(CoM, RZInfo.Position)
            local Distance = Target.magnitude - GatherZoneEdge * RZInfo.Radius
            if Distance >= 0 then
               local Bearing = GetBearingToPoint(RZInfo.Position)
               AdjustHeading(Avoidance(I, Bearing))
               Drive = math.max(0, math.min(1, GatherDriveGain * Distance))
            else
               Drive = 0
            end
            Gathering = true
            -- Only care about the first one
            break
         end
      end

      -- Neither collecting nor gathering
      if not Collecting and not Gathering then
         if ReturnToOrigin then
            local Target,_ = PlanarVector(CoM, I.Waypoint)
            local Distance = Target.magnitude
            if Distance >= OriginMaxDistance then
               local Bearing = GetBearingToPoint(I.Waypoint)
               AdjustHeading(Avoidance(I, Bearing))
               if Vector3.Dot(Target, I:GetConstructForwardVector()) > 0 or Distance >= OriginMaxDistance then
                  Drive = math.max(0, math.min(1, ReturnDriveGain * Distance))
               end
            end
            if not Drive then Drive = 0 end
         else
            -- Just continue along with avoidance active
            AdjustHeading(Avoidance(I, 0))
         end
      end
   end
   if Drive then
      SetThrottle(Drive)
   end
end
