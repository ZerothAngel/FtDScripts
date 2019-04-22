-- Meant for naval surface vehicles with yaw + propulsion control.
-- Destroyer/cruiser variant (cannons + missiles) with (optional) hydrofoil
-- control of depth, pitch, roll. May also carry auxiliary craft.

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
Cannon_UpdateRate = 1
Missile_UpdateRate = 4
ShieldManager_UpdateRate = nil
DockManager_UpdateRate = nil

-- Fixed altitude, measured from CoM (negative for below sea level).
-- Only used when controlling altitude in some way.
-- (see CONTROL CONFIGURATION and HYDROFOIL CONFIGURATION)
FixedAltitude = 0

-- Number of acceleration samples to take for *each* target.
-- Note that a running average is maintained, so it's best to keep this small.
-- Set to nil to disable acceleration sampling.
AccelerationSamples = 120
