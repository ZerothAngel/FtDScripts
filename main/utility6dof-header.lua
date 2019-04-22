-- Meant for vehicles with full six-degrees of freedom movement. This
-- means jets and/or dediblades facing in all 6 directions, balanced around
-- the CoM.
-- Should have material gatherers and/or plenty of cargo space depending on
-- configuration.

-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "Off", "Manual", "Automatic",
-- and "Fleet".
ActivateWhen = {
--   Manual = true,
   Automatic = true,
   Fleet = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
AI_UpdateRate = 4
AltitudeControl_UpdateRate = 4
DockManager_UpdateRate = nil
ShieldManager_UpdateRate = nil
BalloonManager_UpdateRate = nil
