-- Meant for vehicles with full six-degrees of freedom movement. This
-- means jets and/or dediblades facing in all 6 directions, balanced around
-- the CoM.
-- Vehicle should have turreted sensor array(s). Otherwise use my
-- gunship.lua script.

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
-- Set to nil to disable a module.
AI_UpdateRate = 4
Hover_UpdateRate = 4
CameraTrack_UpdateRate = 1
ShieldManager_UpdateRate = nil
BalloonManager_UpdateRate = nil
