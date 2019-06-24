-- CONTROL CONFIGURATION

-- This section enables/disables the control of each axis
-- using a certain means: jets, dediblade spinners, or vehicle controls.

-- The defaults here are suitable for "gunships" -- a vehicle that stays
-- aloft using thrusters or dediblades and has full yaw, lateral, &
-- longitudinal movement. In other words, it can strafe sideways and
-- go in reverse. By default, it uses jets & dediblades for all movement.

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Altitude = 1,
   Yaw = 1,
   Pitch = 1,
   Roll = 1,
   Forward = 1,
   Right = 1,
}
SpinnerFractions = {
   Altitude = 1,
   Yaw = 1,
   Pitch = 1,
   Roll = 1,
   Forward = 1,
   Right = 1,
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
   -- Fake controls, only available through my mod
   Altitude = 0,
   Right = 0,
}
