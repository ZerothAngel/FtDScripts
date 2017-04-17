--@ commons evasion avoidance waypointmove normalizebearing
-- Target AI module
TargetHeading = nil

function TargetAI_Reset()
   TargetHeading = nil
end

function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(I, Waypoint, function (Bearing) AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      Control_MoveToWaypoint(I, Flagship.ReferencePosition + Flagship.Rotation * I.IdealFleetPosition, Flagship.Velocity)
   else
      Control_MoveToWaypoint(I, I.Waypoint) -- Waypoint assumed to be stationary
   end
end

function TargetAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if not TargetHeading then
         TargetHeading = C:Yaw()
      end

      local Bearing = NormalizeBearing(TargetHeading - C:Yaw())
      Bearing = Bearing + CalculateEvasion(TargetEvasion)

      AdjustHeading(Avoidance(I, Bearing))
      SetThrottle(TargetDrive)
   else
      TargetAI_Reset()
      FormationMove(I)
   end
end
