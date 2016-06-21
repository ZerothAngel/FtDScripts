-- CONFIGURABLES

-- If false, your desired altitudes are relative to
-- the ground (or sea level, if over water)
-- If true, then no terrain checking will be done.
AbsoluteAltitude = false

-- How many seconds to look ahead, in terms of velocity
-- You can have any number of points (within reason)
-- If you have terrain avoidance, the furthest point
-- should probably be farther than its look-ahead.
AltitudeLookAhead = { 1, 2, 3, 5, 8, 13, 21, 34 }
-- By default, the horizontal center and both sides of the ship
-- are extended forward and used to check the terrain.
-- If you have a particularly wide ship, you may want to check
-- more points. Use this to increase the number of subdivisions
-- between the center and the sides. Set to 0 for no extra
-- points, 1 for 1 extra between center and side (so 2
-- additional total), etc. Don't go too crazy, because it will
-- increase the number of terrain checks dramatically.
TerrainCheckSubdivisions = 0

-- Desired altitudes
DesiredAltitudeCombat = 100
DesiredAltitudeIdle = 100

-- First number is altitude variation
-- Second is time scale, which should generally be <1.
-- Smaller is slower.
-- Set to nil to disable, e.g. Evasion = nil
Evasion = { 5, .25 }

-- Set to true if the script is allowed to reverse
-- the blades to descend quicker
CanReverseBlades = true

-- PID values. These default values work for me in
-- most ships (very small overshoot).
-- { 1, 0, 0 } is a good starting point when tuning,
-- but probably too slow.
AltitudePIDValues = { 5, 1, 1.5 } -- P, I, D
