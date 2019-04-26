-- CONTROL CONFIGURATION

-- This section enables/disables the control of each axis
-- using a certain means: jets, dediblade spinners, or vehicle controls.

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
-- Control fractions dedicated to vehicle controls for each axis
-- Note that this clashes with JetFractions. Where a clash is
-- indicated, the corresponding axes in JetFractions should be zeroed.
ControlFractions = {
   -- Clashes with JetFractions.Yaw, Forward, AND Right
   Yaw = 0,
   -- Clashes with JetFractions.Altitude, Pitch, AND Roll
   Pitch = 0,
   -- Clashes with JetFractions.Altitude, Pitch, AND Roll
   Roll = 0,
   -- Clashes with JetFractions.Yaw, Forward, AND Right
   Forward = 0,
}

-- ALL DOF CONFIGURATION

-- PID values
True6DoFPIDConfig = {
   Altitude = {
      Kp = .5,
      Ti = 5,
      Td = .1,
   },
   Yaw = {
      Kp = .25,
      Ti = 5,
      Td = .1,
   },
   Pitch = {
      Kp = .25,
      Ti = 5,
      Td = .1,
   },
   Roll = {
      Kp = .25,
      Ti = 5,
      Td = .1,
   },
   North = {
      Kp = .25,
      Ti = 5,
      Td = .1,
   },
   East = {
      Kp = .25,
      Ti = 5,
      Td = .1,
   },
}

-- THRUST HACK CONFIGURATION

-- Use thrust hack instead of standard Lua control of thrusters.
-- Select a complex controller key and make sure all related jets
-- have that key bound as a green input.
-- See Lua box help > Propulsion > RequestComplexControllerStimulus
-- for key mapping.

ThrustHackKey = nil
