--@ planarvector getbearingtopoint evasion
--@ spairs avoidance
-- Collector AI module
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

LastSeenTargets = {}
CollectorDestinations = {}

function PickDestination(ReferencePosition)
   while #CollectorDestinations > 0 do
      local Destination = CollectorDestinations[1]
      local Offset,_ = PlanarVector(ReferencePosition, Destination)
      if Offset.magnitude < CollectMaxDistance then
         return Destination
      else
         -- Too far, remove it and check next
         table.remove(CollectorDestinations, 1)
      end
   end

   return nil
end

function CollectorAI_Update(I)
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

      -- Check if targets are still around
      for _,Target in pairs(LastSeenTargets) do
         if not TargetsById[Target.Id] then
            -- Target gone, make note of its last position
            table.insert(CollectorDestinations, Target.Position)
         end
      end
      -- Current targets become last seen targets
      LastSeenTargets = Targets
   else
      -- Remaining last seen targets also become destinations
      for _,Target in pairs(LastSeenTargets) do
         table.insert(CollectorDestinations, Target.Position)
      end
      LastSeenTargets = {}

      local Collecting = false

      local Destination = PickDestination(I.Fleet.Flagship.CenterOfMass)
      if Destination and I.Resources.NaturalTotal < I.Resources.NaturalMax then
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
         end
      end

      if not Collecting then
         if ReturnToOrigin then
            local Target,_ = PlanarVector(CoM, I.Waypoint)
            if Target.magnitude >= OriginMaxDistance then
               local Bearing = GetBearingToPoint(I.Waypoint)
               AdjustHeading(Avoidance(I, Bearing))
               Drive = ReturnDrive
            else
               Drive = 0
            end
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
