-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
   off = true,
   on = true,
   patrol = true,
   fleetmove = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

ThrottleDriveMaintainerFacing = Vector3.forward

-- To use forward (or reverse!) spinners as propulsion,
-- set either or both of the following options to true.
UseSpinners = false
UseDediBlades = true

ThrottleWhen = {
   patrol = 1,
   fleetmove = 1,
}
