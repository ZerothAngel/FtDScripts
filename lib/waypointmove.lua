--@ planarvector getbearingtopoint
-- Move to a waypoint (using yaw & throttle only)
function MoveToWaypoint(I, Waypoint, AdjustHeading)
   local Drive = 0

   local Target,_ = PlanarVector(CoM, Waypoint)
   local Distance = Target.magnitude
   if Distance >= WaypointMoveMaxDistance then
      local Bearing = GetBearingToPoint(Waypoint)
      AdjustHeading(Bearing)
      if Vector3.Dot(Target, I:GetConstructForwardVector()) > 0 or Distance >= WaypointMoveMaxDistance then
         Drive = math.max(0, math.min(1, WaypointMoveDriveGain * Distance))
      end
   end

   SetThrottle(Drive)
end
