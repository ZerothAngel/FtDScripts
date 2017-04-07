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

-- Determines minimum depth when under manual control. Only used
-- when ManualDepthDriveMaintainerFacing above is non-nil and drive
-- maintainer has negative or zero throttle (absolute depth).
MinManualDepth = 0

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

-- Minimum & maximum depth
-- Only valid when desired depth is relative.
-- Should be 0 or positive.
MinDepth = 50
MaxDepth = 500

-- If set, vertical dodging will be enabled.
-- The vehicle will absolutely never attempt to go below this depth
-- after summing up desired depth, dodging, etc.
HardMaxDepth = nil -- luacheck: ignore 131
