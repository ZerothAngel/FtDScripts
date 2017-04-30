-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
--   on = true,
   combat = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 1

TiltSpinnerPIDConfig = {
   Kp = .01,
   Ti = 10,
   Td = 0,
}

TestAngle = 45
