-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
--   off = true,
   on = true,
   combat = true,
   patrol = true,
   fleetmove = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 1

-- Number of acceleration samples to take for *each* target.
-- Note that a running average is maintained, so it's best to keep this small.
-- Set to nil to disable acceleration sampling.
AccelerationSamples = 120
