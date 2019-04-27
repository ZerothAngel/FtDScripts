--@ commons control getbearingtopoint evasion avoidance waypointmove clamp
-- Utility AI module (yaw & throttle)

function UtilityAI_RunAway(I, EnemyDirection)
   if EnemyDirection then
      -- And head in the opposite direction
      local Bearing = GetBearingToPoint(C:CoM() - EnemyDirection)
      Bearing = Bearing + CalculateEvasion(RunAwayEvasion)
      V.AdjustHeading(Avoidance(I, Bearing))
      V.SetThrottle(RunAwayDrive)
   else
      V.SetSpeed(0)
   end
end

function UtilityAI_MoveToCollect(I, Destination)
   local Bearing = GetBearingToPoint(Destination)
   V.AdjustHeading(Avoidance(I, Bearing))
   V.SetThrottle(CollectDrive)
end

function UtilityAI_MoveToGather(I, RZInfo)
   local Target,_ = PlanarVector(C:CoM(), RZInfo.Position)
   local Distance = Target.magnitude - GatherZoneEdge * RZInfo.Radius
   if Distance >= 0 then
      local Bearing = GetBearingToPoint(RZInfo.Position)
      V.AdjustHeading(Avoidance(I, Bearing))
      V.SetThrottle(Clamp(GatherDriveGain * Distance, 0, 1))
   else
      V.SetSpeed(0)
   end
end

function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(Waypoint, function (Bearing) V.AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
end

function UtilityAI_FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      Control_MoveToWaypoint(I, Flagship.ReferencePosition + Flagship.Rotation * I.IdealFleetPosition, Flagship.Velocity)
   else
      Control_MoveToWaypoint(I, I.Waypoint) -- Waypoint assumed to be stationary
   end
end
