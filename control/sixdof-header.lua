-- 6DOF CONFIGURATION

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Altitude = 1,
   Yaw = 1,
   Pitch = 1,
   Roll = 1,
   Forward = 1,
   Right = 1,
}
SpinnerFractions = {
   Altitude = 1,
   Yaw = 1,
   Pitch = 1,
   Roll = 1,
   Forward = 1,
   Right = 1,
}
-- Control fractions dedicated to vehicle controls for each axis
-- Note that this clashes with JetFractions. Where a clash is
-- indicated, the corresponding axes in JetFractions should be zeroed.
ControlFractions = {
   -- Clashes with JetFractions.Yaw AND Right
   Yaw = 0,
   -- Clashes with JetFractions.Altitude, Pitch, AND Roll
   Pitch = 0,
   -- Clashes with JetFractions.Altitude, Pitch, AND Roll
   Roll = 0,
   -- Clashes with JetFractions.Forward
   Forward = 0,
}

-- PID values
AltitudePIDConfig = {
   Kp = 5,
   Ti = 5,
   Td = .3,
}
YawPIDConfig = {
   Kp = .3,
   Ti = 5,
   Td = .4,
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
ForwardPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}
RightPIDConfig = {
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

-- Drive maintainer facing for altitude/pitch/roll
-- (upward- and downward-facing thrusters)
APRThrustHackDriveMaintainerFacing = nil

-- Drive maintainer facing for yaw/longitudinal/lateral
-- (forward-, reverse-, left-, and right-facing thrusters)
YLLThrustHackDriveMaintainerFacing = nil
