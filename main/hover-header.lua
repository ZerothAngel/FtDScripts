-- CONFIGURABLES

-- If false, your desired altitudes are relative to
-- the ground (or sea level, if over water)
AbsoluteAltitude = false

-- How many seconds to look ahead, in terms of velocity
-- You can have any number of points (within reason)
-- If you have terrain avoidance, the furthest point
-- should probably be farther than its look-ahead.
AltitudeLookAhead = { 5, 30 }

-- Desired altitudes
DesiredAltitudeCombat = 100
DesiredAltitudeIdle = 100

-- Set to true if the script is allowed to reverse
-- the blades to descend quicker
CanReverseBlades = true

-- PID values. These default values work for me in
-- most ships (very small overshoot).
-- { 1, 0, 0 } is a good starting point when tuning,
-- but probably too slow.
AltitudePIDValues = { 5, 1, 1.5 } -- P, I, D
