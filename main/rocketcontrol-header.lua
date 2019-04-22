-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "Off", "Manual", "Automatic",
-- and "Fleet".
ActivateWhen = {
   Manual = true,
   Automatic = true,
   Fleet = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 1

-- Weapon slot of turrets to aim
RocketWeaponSlot = 1

-- Average speed of rockets. Note that ejectors and var thrust ramp up will
-- likely throw things off.
-- Missiles/torpedoes don't travel at a constant speed anyway, so this
-- will need some tuning for a given engagement range.
-- Decrease speed to increase lead, increase speed to decrease lead.
RocketSpeed = 65
