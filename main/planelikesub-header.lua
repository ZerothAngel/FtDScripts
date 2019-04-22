-- Meant for vehicles with yaw, pitch, roll and propulsion control.
-- Basically anything that must keep moving forward to fly.

-- CONFIGURATION

-- See https://github.com/ZerothAngel/FtDScripts/blob/master/main/airplane.md for details.

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
DepthControl_UpdateRate = 4
Missile_UpdateRate = 4
ShieldManager_UpdateRate = nil
