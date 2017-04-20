-- DODGE SETTINGS

-- Vehicle radius for determining the size of the defensive sphere.
-- Any missiles predicted to impact the sphere will cause an evasive
-- maneuver to dodge.
-- Set to nil to use the vehicle's longest (half) dimension multiplied
-- by the padding factor below.
VehicleRadius = nil

-- Only used when VehicleRadius is nil. Multiplied against half of the
-- longest dimension of the vehicle to set VehicleRadius.
VehicleRadiusPadding = 2

-- Mainframe to use for missile warnings.
-- Set to nil to disable dodging.
MissileWarningMainframe = 0

-- Only consider missiles that are predicted to impact within this
-- number of seconds.
DodgeTimeHorizon = 10