-- Meant for naval surface vessels with yaw + propulsion control that serve
-- as carriers (by way of having one or more tractor beams).

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
DockManager_UpdateRate = 20
ShieldManager_UpdateRate = nil
