-- APR 3DOF CONFIGURATION

-- Switches to enable/disable control of each axis.
ControlAltitude = true
ControlPitch = true
ControlRoll = true

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Altitude = 1,
   Pitch = 1,
   Roll = 1,
}
SpinnerFractions = {
   Altitude = 1,
   Pitch = 1,
   Roll = 1,
}

-- PID values
AltitudePIDConfig = {
   Kp = 5,
   Ti = 5,
   Td = .3,
}
PitchPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}
RollPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}

-- Spinner configuration

-- The dediblade "always up" feature requires special handling.
-- If you set the following to true, then ALL upward- and downward-
-- facing dediblades should have "always up" set to 1.
-- Use of "always up" is generally not recommended.
DediBladesAlwaysUp = false

-- THRUST HACK CONFIGURATION

-- Use thrust hack instead of standard Lua control of thrusters.
-- Requires a drive maintainer facing in the given direction.
-- Drive maintainer should be set up on its own drive (e.g. tertiary).
-- All related jets should be bound to that drive.
APRThrustHackDriveMaintainerFacing = nil
