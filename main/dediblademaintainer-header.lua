-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
   off = true,
   on = true,
--   combat = true,
   patrol = true,
   fleetmove = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

-- Drive maintainer to read for propulsion. Since the Lua interface
-- lacks a method to uniquely identify blocks, using their orientation
-- is one way to find them. The first drive maintainer facing in
-- this direction will be used as throttle for the dediblades.
-- Other useful values: Vector3.left, Vector3.right, Vector3.back, etc.
ThrottleDriveMaintainerFacing = Vector3.forward

-- Simply set throttle to the given value (-1 to 1) on these AI modes.
-- If a mode is not listed below, then the dediblade speed will be
-- based on the drive maintainer reading (assuming it is actually
-- active in ActivateWhen above).
-- By default, "off" and "on" will read the drive maintainer,
-- "patrol" and "fleetmove" will go full throttle.
-- Note that "combat" is assumed to be taken care of by the combat AI...
ThrottleWhen = {
   patrol = 1,
   fleetmove = 1,
}
