CruiseMissileConfig.UpdateRate = AI_UpdateRate

-- Default minimum speed is 40 for airplanes.
if not VehicleConfig.MinimumSpeed then VehicleConfig.MinimumSpeed = 40 end
-- And don't stop at waypoints
if WaypointMoveConfig.StopOnStationaryWaypoint == nil then WaypointMoveConfig.StopOnStationaryWaypoint = false end

-- Max altitude for interpolation of pitch table
PlaneLike_MaxAltitude = 500
