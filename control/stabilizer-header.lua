-- ROLL/PITCH STABILIZATION

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

-- PID values for stabilization using propulsion elements.
-- Start with { 1, 0, 0 } and tune from there.
RollPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}
PitchPIDConfig = {
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
