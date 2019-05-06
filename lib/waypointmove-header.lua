-- WAYPOINT MOVE SETTINGS

-- Governs behavior when trying to move towards a waypoint.
-- If flagship, then this is the 'M' map waypoint (a stationary waypoint).
-- If not the flagship, this is the formation waypoint relative to the
-- flagship (which moves with the flagship).

WaypointMoveConfig = {
   -- Whether or not to stop at stationary waypoints.
   -- If false, then the VehicleConfig.MinimumSpeed will be used instead.
   -- If nil, it will use the script's default, which is usually "true".
   StopOnStationaryWaypoint = nil,
   -- Maximum distance from stationary waypoints.
   -- If further than this, set throttle to ClosingDrive (below).
   -- Should be comparable (e.g. slightly larger) to ship's turning radius.
   MaxWanderDistance = 250,

   -- If farther away than this from a moving waypoint, set throttle
   -- to ClosingDrive (below).
   MaxFormationDistance = 100,
   -- Throttle when distance from waypoint is >ClosingDistance.
   ClosingDrive = 1,
   -- Speed relative to waypoint in meters per second when within
   -- ClosingDistance. Our speed will be the waypoint speed +/- this.
   RelativeClosingSpeed = 1,
}
