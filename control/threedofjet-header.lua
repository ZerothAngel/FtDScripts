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
