-- 3DOF JET CONFIGURATION

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

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

-- THRUST HACK CONFIGURATION

-- Use thrust hack instead of standard Lua control of thrusters.
-- Requires a drive maintainer facing in the given direction.
-- Drive maintainer should be set up on its own drive (e.g. tertiary).
-- All related jets should be bound to that drive.
ThrustHackDriveMaintainerFacing = nil
