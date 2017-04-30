-- ALL DOF CONFIGURATION

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Altitude = 1,
   Yaw = 1,
   Pitch = 1,
   Roll = 1,
   North = 1,
   East = 1,
   Forward = 1,
}
SpinnerFractions = {
   Altitude = 1,
   Yaw = 1,
   Pitch = 1,
   Roll = 1,
   North = 1,
   East = 1,
   Forward = 1,
}

-- PID values
AllDoFPIDConfig = {
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
   North = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
   East = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
}

-- THRUST HACK CONFIGURATION

-- Use thrust hack instead of standard Lua control of thrusters.
-- Requires a drive maintainer facing in the given direction.
-- Drive maintainer should be set up on its own drive (e.g. tertiary).
-- All related jets should be bound to that drive.

ThrustHackDriveMaintainerFacing = nil
