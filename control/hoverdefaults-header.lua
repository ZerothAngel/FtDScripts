-- CONTROL CONFIGURATION

-- This section enables/disables the control of each axis
-- using a certain means: jets, dediblade spinners, or vehicle controls.

-- The defaults here are strictly for hovering using jets and/or
-- dediblades.

-- Generally, if this is included in a script, then hovering is all it
-- does and changing other fractions won't do anything.

-- Control fractions dedicated to jets & spinners for each axis
JetFractions = {
   Altitude = 1,
   Yaw = 0,
   Pitch = 1,
   Roll = 1,
   Forward = 0,
   Right = 0,
}
SpinnerFractions = {
   Altitude = 1,
   Yaw = 0,
   Pitch = 1,
   Roll = 1,
   Forward = 0,
   Right = 0,
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
