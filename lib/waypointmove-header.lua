-- WAYPOINT MOVE SETTINGS

WaypointMoveConfig = {
   -- Maximum distance from stationary waypoints.
   -- If further than this, set throttle to ClosingDrive (below).
   -- Should be comparable to ship's turning radius.
   MaxDistance = 250,
   -- If farther away than this from a moving waypoint, set throttle
   -- to ClosingDrive (below).
   ApproachDistance = 100,
   -- Throttle when distance from waypoint is >ApproachDistance.
   ClosingDrive = 1,
   -- Speed relative to waypoint in meters per second when within
   -- ApproachDistance. Our speed will be the waypoint speed +/- this.
   RelativeApproachSpeed = 1,
   -- Whether or not to stop at stationary waypoints (i.e. the 'M' map
   -- waypoint when this vehicle is the flagship). If false, then the
   -- MinimumSpeed will be used instead.
   -- If nil, it will use the script's default, which is usually "true".
   StopOnStationaryWaypoint = nil,
}
