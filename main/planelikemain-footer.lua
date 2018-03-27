-- Control mode. Set to WATER, LAND, or AIR.
Mode = AIR

-- Default minimum speed is 40 for airplanes.
if not WaypointMoveConfig.MinimumSpeed then WaypointMoveConfig.MinimumSpeed = 40 end
-- And don't stop at waypoints
if WaypointMoveConfig.StopOnStationaryWaypoint == nil then WaypointMoveConfig.StopOnStationaryWaypoint = false end

-- Max altitude for interpolation of pitch table
PlaneLike_MaxAltitude = 500
