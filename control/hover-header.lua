-- HOVER CONTROL

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

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