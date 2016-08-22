-- HOVER CONFIGURATION

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
DediBladesAlwaysUp = true
