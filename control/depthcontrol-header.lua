-- DEPTH CONTROL

-- Set to false to disable depth control
ControlDepth = true

-- Switch to manual depth control on these AI modes. Valid keys are "off",
-- "on", "combat", "patrol", and "fleetmove".
-- Only used when ManualDepthDriveMaintainerFacing below is non-nil.
ManualDepthWhen = {
   off = true,
   on = true,
   combat = true,
   patrol = true,
   fleetmove = true,
}

-- Manual depth control (optional, default disabled)
-- There's no easy way to get input from the player, so this is a bit of
-- a hack.
-- Set the following to an axis-aligned unit Vector3, i.e. Vector3.forward,
-- Vector3.up, Vector3.left, etc.
-- Then place a drive maintainer block facing that direction. It should be the
-- only drive maintainer facing that direction.
-- You can then assign keys to that drive maintainer. If you have other drive
-- maintainers, make sure this one uses an unused drive (primary/secondary/
-- tertiary).
-- Positive drive means relative to sea floor: 0 = 500m above sea floor,
--   1 = 0m above sea floor (not recommended)
-- Negative drive corresponds to absolute depth: 0 = 0m, -1 = -500m
-- Set to nil to use the configured depth settings (below).
ManualDepthDriveMaintainerFacing = nil

-- Desired depths for combat and out-of-combat.
-- First value is the desired depth or elevation and should always be
-- positive.
-- Second value is true/false indicating whether it is absolute (true) or
-- relative to terrain (false).
-- If relative, then first number is elevation above sea terrain.
-- Otherwise, it is depth below sea level (0).
DesiredDepthCombat = {
   Depth = 20,
   Absolute = false
}
DesiredDepthIdle = {
   Depth = 0,
   Absolute = true
}

-- Minimum & maximum depth when following terrain.
-- Only valid when desired depth is relative.
-- Should be 0 or positive.
-- This differs from the hard limits below in that it lets you specify
-- narrower constraints to give more leeway when dodging/evading.
TerrainMinDepth = 50
TerrainMaxDepth = 500

-- Enable vertical dodging of torpedoes (when combined AI supports it)
DepthDodging = false

-- Hard constraints on depth after summing up desired depth, dodging,
-- evasion, etc. These are absolute depth values.
HardMinDepth = 0
HardMaxDepth = 500

-- First number is depth variation
-- Second is time scale, which should generally be <1.
-- Smaller is slower.
-- Set to nil to disable, e.g. DepthEvasion = nil
DepthEvasion = nil

-- Whether or not to apply the above evasion settings when under manual
-- control.
ManualEvasion = true
