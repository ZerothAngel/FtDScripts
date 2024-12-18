-- Meant for naval surface vehicles with yaw + propulsion control.
-- If it is a hydrofoil-based surface or submarine vessel, see my
-- submarine.lua instead.
-- If it is an airship, see airship.lua instead.

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
Missile_UpdateRate = 4
ShieldManager_UpdateRate = nil
DockManager_UpdateRate = nil

-- Fixed altitude, measured from CoM (negative for below sea level).
-- Only used when controlling altitude in some way.
-- (see CONTROL CONFIGURATION)
FixedAltitude = 0
