-- HOVER CONTROL

-- If false, your desired altitudes are relative to
-- the ground (or sea level, if over water)
-- If true, then no terrain checking will be done.
AbsoluteAltitude = false

-- Desired altitudes
DesiredAltitudeCombat = 100
DesiredAltitudeIdle = 100

-- Only used when AbsoluteAltitude is false AND TerrainCheckLookAheadTime
-- (see below) is nil.
-- This helps determine look ahead distance.
-- Think of it as the tallest obstacle the terrain checker will try to
-- fly over.
MaxAltitude = 300

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
AltitudePIDConfig = {
   Kp = 5,
   Ti = 5,
   Td = 0.3,
}

-- The weird thing about dedicated heliblade spinners is that "always up"
-- only means "up" when rotating clockwise. When oriented upside down,
-- they don't behave in the expected/intuitive way. You have to rotate
-- it clockwise rather than counter-clockwise as you would when the
-- "always up fraction" is 0.
-- Set to true if the dedicated heliblade spinners have a positive
-- "always up fraction." Note that Lua scripts can't read this value, so
-- it is best to set it on the spinner to 1 or 0.
DediSpinnersAlwaysUp = true
