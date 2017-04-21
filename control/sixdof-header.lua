-- 6DOF CONFIGURATION

-- PID values
SixDoFPIDConfig = {
   Altitude = {
      Kp = 5,
      Ti = 5,
      Td = .3,
   },
   Yaw = {
      Kp = .3,
      Ti = 5,
      Td = .4,
   },
   Pitch = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
   Roll = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
   Forward = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
   Right = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
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
