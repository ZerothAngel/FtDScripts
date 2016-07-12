-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true
ControlDepth = true

-- Manual depth control
-- There's no easy way to get input from the player, so this is a bit of a hack.
-- Set the following to an axis-aligned unit Vector3, i.e. Vector3.forward,
-- Vector3.up, Vector3.left, etc.
-- Then place a drive maintainer block facing that direction. It should be the
-- only drive maintainer facing that direction.
-- You can then assign keys to that drive maintainer. If you have other drive
-- maintainers, make sure this one uses an unused drive (primary/secondary/tertiary).
-- Positive drive means relative to sea floor: 0 = 500m above sea floor,
--   1 = 0m above sea floor (not recommended)
-- Negative drive corresponds to absolute depth: 0 = 0m, -1 = -500m
ManualDepthDriveMaintainerFacing = nil

-- Desired depth for combat and out-of-combat.
-- First value is the desired depth/altitude.
-- Second value true/false indicating whether it is absolute (true) or
-- relative to terrain (false).
-- If relative, then first number is altitude above sea terrain.
-- Otherwise, it is depth below sea level (0).
DesiredDepthCombat = { 20, false }
DesiredDepthIdle = { 0, true }

-- Minimum depth.
-- Only valid when desired depth is relative.
MinDepth = 50

-- PID values for hydrofoils
-- Start with { 1, nil, 0 } and tune from there.
-- Setting Ti to nil eliminates integral component.
RollPIDConfig = {
   Kp = .01,
   Ti = 40,
   Td = .4,
}
PitchPIDConfig = {
   Kp = .1,
   Ti = 20,
   Td = .5,
}
DepthPIDConfig = {
   Kp = 1,
   Ti = nil,
   Td = 0,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4
