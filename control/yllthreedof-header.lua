-- YLL 3DOF CONFIGURATION

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Yaw = 1,
   Forward = 1,
   Right = 1,
}
SpinnerFractions = {
   Yaw = 1,
   Forward = 1,
   Right = 1,
}

-- PID values
YawPIDConfig = {
   Kp = .3,
   Ti = 5,
   Td = .4,
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
YLLThrustHackDriveMaintainerFacing = nil
