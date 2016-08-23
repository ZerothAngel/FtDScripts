--@ planarvector getbearingtopoint evasion
--@ spairs avoidance yawthrottle
-- Gatherer AI module
function GetTargets(I)
   local Targets = {}
   for i = 0,I:GetNumberOfTargets(0)-1 do
      local TargetInfo = I:GetTargetInfo(0, i)
      if TargetInfo.Valid and TargetInfo.Protected then
         table.insert(Targets, TargetInfo.Position)
      end
   end
   return Targets
end

function GetResourceZones(I, ReferencePosition)
   local ResourceZones = {}
   for i = 1,#I.ResourceZones do
      local ResourceZone = I.ResourceZones[i]
      local Distance = (ResourceZone.Position - ReferencePosition).magnitude
      if Distance < GatherMaxDistance then
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

function GathererAI_Update(I)
   YawThrottle_Reset()

   local Drive = nil

   local Targets = GetTargets(I)
   if #Targets > 0 then
      -- Sum up the inverse of all enemy vectors
      local RunAway,Count = Vector3.zero,0
      for _,TargetPosition in pairs(Targets) do
         local Offset,_ = PlanarVector(CoM, TargetPosition)
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
   else
      local Gathering = false

      if not I.IsFlagship and I.Resources.NaturalTotal < I.Resources.NaturalMax then
         local FlagshipPosition = I.Fleet.Flagship.CenterOfMass
         local ResourceZones = GetResourceZones(I, FlagshipPosition)
         for _,RZInfo in spairs(ResourceZones, function(t,a,b) return t[a].Distance < t[b].Distance end) do
            local Target,_ = PlanarVector(CoM, RZInfo.Position)
            local Distance = Target.magnitude
            if Distance >= GatherMinDistance then
               local Bearing = GetBearingToPoint(RZInfo.Position)
               AdjustHeading(Avoidance(I, Bearing))
               if Distance >= RZInfo.Radius then
                  Drive = GatherDrive
               else
                  Drive = GatherApproachDrive
               end
            else
               Drive = 0
            end
            Gathering = true
            -- Only care about the first one
            break
         end
      end

      if not Gathering then
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
