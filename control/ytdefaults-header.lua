-- CONTROL CONFIGURATION

-- This section enables/disables the control of each axis
-- using a certain means: jets, dediblade spinners, or vehicle controls.

-- The defaults here are suitable for standard vehicle yaw/throttle
-- controls and can be augmented for dediblade spinners (for both yaw
-- and/or propulsion).

-- Generally, if a script includes these defaults, then altitude/
-- pitch/roll are controlled by some other way (hydrofoils, pumps, etc.)
-- and those fractions here should always be 0.

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Altitude = 0,
   Yaw = 0,
   Pitch = 0,
   Roll = 0,
   Forward = 0,
   Right = 0,
}
-- Control fractions dedicated to vehicle controls for each axis
-- Note that this clashes with JetFractions. Where a clash is
-- indicated, the corresponding axes in JetFractions should be zeroed.
ControlFractions = {
   -- Clashes with JetFractions.Yaw, Forward, AND Right
   Yaw = 1,
   -- Clashes with JetFractions.Altitude, Pitch, AND Roll
   Pitch = 0,
   -- Clashes with JetFractions.Altitude, Pitch, AND Roll
   Roll = 0,
   -- Clashes with JetFractions.Yaw, Forward, AND Right
   Forward = 1,
   -- Fake controls, only available through my mod
   Altitude = 0,
   Right = 0,
}
