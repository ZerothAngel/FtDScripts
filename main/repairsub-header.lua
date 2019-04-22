-- Meant for naval surface or submarine vehicles with yaw + propulsion
-- control.
-- Should have hydrofoils in front of and behind the CoM, otherwise use
-- a different script (repair-ai.lua, repair.lua).
-- Vehicle should have repair tentacles and material storage.

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
DepthControl_UpdateRate = 4
ShieldManager_UpdateRate = nil
