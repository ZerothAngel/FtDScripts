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
