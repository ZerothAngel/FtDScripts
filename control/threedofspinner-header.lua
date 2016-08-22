-- 3DOF SPINNER CONFIGURATION

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

-- PID values
AltitudePIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .3,
}
PitchPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .3,
}
RollPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .3,
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
