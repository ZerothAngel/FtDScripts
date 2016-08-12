-- THREE-AXIS PUMP CONFIGURATION

-- Switch to manual altitude control on these AI modes. Valid keys are "off",
-- "on", "combat", "patrol", and "fleetmove".
-- Only used when ManualAltitudeDriveMaintainerFacing below is non-nil.
ManualAltitudeWhen = {
   off = true,
   on = true,
   combat = true,
   patrol = true,
   fleetmove = true,
}

-- Manual altitude control (optional, default disabled)
-- Set the following to an axis-aligned unit Vector3, i.e. Vector3.forward,
-- Vector3.up, Vector3.left, etc.
-- Then place a drive maintainer block facing that direction. It should be the
-- only drive maintainer facing that direction.
ManualAltitudeDriveMaintainerFacing = nil

-- Determines scaling for manual altitude control. -1.0 throttle on the
-- drive maintainer means 0 altitude, 1.0 throttle means MaxManualAltitude.
-- Only used when ManualAltitudeDriveMaintainerFacing above is non-nil.
MaxManualAltitude = 400

-- If false, your desired altitudes are relative to
-- the ground (or sea level, if over water)
-- If true, then no terrain checking will be done.
AbsoluteAltitude = false

-- Desired altitudes
DesiredAltitudeCombat = 100
DesiredAltitudeIdle = 100

-- Only used when AbsoluteAltitude is false AND TerrainCheckLookAheadTime
-- (see below) is nil.
-- This helps determine look ahead distance.
-- Think of it as the tallest obstacle the terrain checker will try to
-- fly over.
MaxAltitude = 300

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

-- PID values
AltitudePIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
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
