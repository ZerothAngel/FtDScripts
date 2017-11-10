-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
--   on = true,
   combat = true,
   fleetmove = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
AI_UpdateRate = 4
Cannon_UpdateRate = 1
Missile_UpdateRate = nil
ShieldManager_UpdateRate = nil

-- Number of acceleration samples to take for *each* target.
-- Note that a running average is maintained, so it's best to keep this small.
-- Set to nil to disable acceleration sampling.
AccelerationSamples = 120
