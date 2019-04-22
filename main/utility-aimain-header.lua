-- Meant for vehicles with yaw + propulsion control.
-- If it is a submarine, depth must be controlled some other means (or
-- see my utilitysub.lua script for hydrofoil-based vehicles).
-- If it is an airship, see my utility.lua script instead.
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
UpdateRate = 4
