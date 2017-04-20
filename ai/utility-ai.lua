--@ commons getbearingtopoint evasion avoidance waypointmove
-- Utility AI module (yaw & throttle)

function UtilityAI_RunAway(I, EnemyDirection)
   local Drive = 0
   if EnemyDirection then
      -- And head in the opposite direction
      local Bearing = GetBearingToPoint(C:CoM() - EnemyDirection)
      Bearing = Bearing + CalculateEvasion(RunAwayEvasion)
      AdjustHeading(Avoidance(I, Bearing))
      Drive = RunAwayDrive
   end
   SetThrottle(Drive)
end

function UtilityAI_MoveToCollect(I, Destination)
   local Bearing = GetBearingToPoint(Destination)
   AdjustHeading(Avoidance(I, Bearing))
   SetThrottle(CollectDrive)
end

function UtilityAI_MoveToGather(I, RZInfo)
   local Target,_ = PlanarVector(C:CoM(), RZInfo.Position)
   local Distance = Target.magnitude - GatherZoneEdge * RZInfo.Radius
   local Drive = 0
   if Distance >= 0 then
      local Bearing = GetBearingToPoint(RZInfo.Position)
      AdjustHeading(Avoidance(I, Bearing))
      Drive = math.max(0, math.min(1, GatherDriveGain * Distance))
   end
   SetThrottle(Drive)
end

function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(I, Waypoint, function (Bearing) AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
end

function UtilityAI_FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      Control_MoveToWaypoint(I, Flagship.ReferencePosition + Flagship.Rotation * I.IdealFleetPosition, Flagship.Velocity)
   else
      Control_MoveToWaypoint(I, I.Waypoint) -- Waypoint assumed to be stationary
   end
end
