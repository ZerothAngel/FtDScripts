--@ planarvector getbearingtopoint evasion
--@ spairs avoidance waypointmove
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

function UtilityAI_Reset(I)
   CollectorDestinations = {}
end

function UtilityAI_Main(I)
   local Targets,TargetsById = GetTargets(I)
   if #Targets > 0 then
      -- Sum up the all enemy direction vectors
      local RunAway,Count = Vector3.zero,0
      for _,Target in pairs(Targets) do
         local Offset,_ = PlanarVector(CoM, Target.Position)
         local Distance = Offset.magnitude
         if Distance < RunAwayDistance then
            RunAway = RunAway + Offset / Distance
            Count = Count + 1
         end
      end

      local Drive = 0
      if Count > 0 then
         -- And head in the opposite direction
         local Bearing = GetBearingToPoint(CoM - RunAway)
         Bearing = CalculateEvasion(RunAwayEvasion, Bearing)
         AdjustHeading(Avoidance(I, Bearing))
         Drive = RunAwayDrive
      end
      SetThrottle(Drive)

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

      return true
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
      local HasRoom= I.Resources.NaturalTotal < (FreeStorageThreshold * I.Resources.NaturalMax)

      -- Collector logic
      local Collecting = false
      if IsCollector then
         local Destination = PickDestination(FlagshipPosition)
         while Destination and HasRoom do
            local Target,_ = PlanarVector(CoM, Destination)
            local Distance = Target.magnitude
            if Distance >= CollectMinDistance then
               local Bearing = GetBearingToPoint(Destination)
               AdjustHeading(Avoidance(I, Bearing))
               SetThrottle(CollectDrive)
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
         for _,RZInfo in spairs(ResourceZones, function(t,a,b) return t[a].Distance < t[b].Distance end) do
            local Target,_ = PlanarVector(CoM, RZInfo.Position)
            local Distance = Target.magnitude - GatherZoneEdge * RZInfo.Radius
            local Drive = 0
            if Distance >= 0 then
               local Bearing = GetBearingToPoint(RZInfo.Position)
               AdjustHeading(Avoidance(I, Bearing))
               Drive = math.max(0, math.min(1, GatherDriveGain * Distance))
            end
            SetThrottle(Drive)
            Gathering = true
            -- Only care about the first one
            break
         end
      end

      return Collecting or Gathering
   end
end

function Control_MoveToWaypoint(I, Waypoint)
   MoveToWaypoint(I, Waypoint, function (Bearing) AdjustHeading(Avoidance(I, Bearing)) end)
end

function UtilityAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if not UtilityAI_Main(I) then
         if ReturnToOrigin then
            Control_MoveToWaypoint(I, I.Waypoint)
         else
            -- Just continue along with avoidance active
            AdjustHeading(Avoidance(I, 0))
         end
      end
   else
      UtilityAI_Reset()

      if I.IsFlagship then
         Control_MoveToWaypoint(I, I.Waypoint)
      else
         local Flagship = I.Fleet.Flagship
         if Flagship.Valid then
            local FlagshipRotation = Flagship.Rotation
            Control_MoveToWaypoint(I, Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition)
         end
      end
   end
end
