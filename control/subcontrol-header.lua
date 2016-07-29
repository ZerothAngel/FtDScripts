-- HYDROFOIL CONTROL

-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true
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

-- Minimum depth.
-- Only valid when desired depth is relative.
-- Should be 0 or positive.
MinDepth = 50

-- PID values for hydrofoils
-- Start with { 1, 0, 0 } and tune from there.
RollPIDConfig = {
   Kp = .01,
   Ti = 10,
   Td = .1,
}
PitchPIDConfig = {
   Kp = .1,
   Ti = 5,
   Td = .125,
}
DepthPIDConfig = {
   Kp = 1,
   Ti = 0,
   Td = 0,
}

-- If true then the angles of hydrofoils closer to the Center of Mass
-- (on both X and Z axes) will be scaled up in proportion to the
-- distance of the furthest hydrofoil.
ScaleByCoMOffset = true
