-- 3DOF PUMP CONFIGURATION

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

-- PID values
ThreeDoFPumpPIDConfig = {
   Altitude = {
      Kp = .5,
      Ti = 5,
      Td = .1,
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
}
