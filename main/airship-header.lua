-- Meant for vehicles with yaw + propulsion control that have
-- an independent means for staying aloft (jets and/or dediblades).

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
AltitudeControl_UpdateRate = 4
Missile_UpdateRate = 4
ShieldManager_UpdateRate = nil
BalloonManager_UpdateRate = nil
