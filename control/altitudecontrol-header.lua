-- ALTITUDE CONTROL

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
-- drive maintainer means MinManualAltitude, 1.0 throttle means MaxManualAltitude.
-- Only used when ManualAltitudeDriveMaintainerFacing above is non-nil.
MinManualAltitude = 0
MaxManualAltitude = 400

-- If false, your desired altitudes are relative to
-- the ground (or sea level, if over water)
-- If true, then no terrain checking will be done.
AbsoluteAltitude = false

-- Desired altitudes
DesiredAltitudeCombat = 100
DesiredAltitudeIdle = 100

-- Never go below this altitude after summing up desired altitude,
-- evasion, dodging, etc.
-- Default is to never go below sea level, which is a safe but
-- impractical default. You will probably want to set this higher.
-- This is always an absolute altitude and is not relative to terrain.
MinAltitude = 0

-- Only used when AbsoluteAltitude is false AND TerrainCheckLookAheadTime
-- (see below) is nil.
-- This helps determine look ahead distance.
-- Think of it as the tallest obstacle the terrain checker will try to
-- fly over.
MaxLookAheadAltitude = 300

-- First number is altitude variation
-- Second is time scale, which should generally be <1.
-- Smaller is slower.
-- Set to nil to disable, e.g. Evasion = nil
Evasion = { 5, .25 }

-- Whether or not to apply the above evasion settings when under manual control.
ManualEvasion = true
