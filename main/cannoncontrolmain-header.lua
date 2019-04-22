-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "Off", "Manual", "Automatic",
-- and "Fleet".
ActivateWhen = {
--   off = true,
   Manual = true,
   Automatic = true,
   Fleet = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 1

-- Number of acceleration samples to take for *each* target.
-- Note that a running average is maintained, so it's best to keep this small.
-- Set to nil to disable acceleration sampling.
AccelerationSamples = 120
