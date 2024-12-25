-- 6DOF CONFIGURATION

-- PID values
SixDoFPIDConfig = {
   Altitude = {
      Kp = .1,
      Ti = 5,
      Td = .3,
   },
   Yaw = {
      Kp = .01,
      Ti = 5,
      Td = .4,
   },
   Pitch = {
      Kp = .01,
      Ti = 5,
      Td = .1,
   },
   Roll = {
      Kp = .01,
      Ti = 5,
      Td = .1,
   },
   Forward = {
      Kp = .01,
      Ti = 5,
      Td = .1,
   },
   Right = {
      Kp = .01,
      Ti = 5,
      Td = .1,
   },
}
