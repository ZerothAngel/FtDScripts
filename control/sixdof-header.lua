-- 6DOF CONFIGURATION

-- PID values
SixDoFPIDConfig = {
   Altitude = {
      Kp = .15,
      Ti = 5,
      Td = .3,
   },
   Yaw = {
      Kp = .01,
      Ti = 5,
      Td = .4,
   },
   Pitch = {
      Kp = .015,
      Ti = 5,
      Td = .1,
   },
   Roll = {
      Kp = .015,
      Ti = 5,
      Td = .1,
   },
   Forward = {
      Kp = .015,
      Ti = 5,
      Td = .1,
   },
   Right = {
      Kp = .015,
      Ti = 5,
      Td = .1,
   },
}

-- THRUST HACK CONFIGURATION

-- Use thrust hack instead of standard Lua control of thrusters.
-- Select a complex controller key for each related axes.
-- All related jets should be bound to that key as a green input.
-- See Lua box help > Propulsion > RequestComplexControllerStimulus
-- for key mapping.

-- Complex controller key for altitude/pitch/roll
-- (upward- and downward-facing thrusters)
APRThrustHackKey = nil

-- Complex controller key for yaw/longitudinal/lateral
-- (forward-, reverse-, left-, and right-facing thrusters)
YLLThrustHackKey = nil
