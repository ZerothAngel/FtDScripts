-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
   on = true,
   combat = true,
   patrol = true,
   fleetmove = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 1

-- Mainframe to use for target priorities
RocketMainframe = 0

-- Weapon slot of turrets to aim
RocketWeaponSlot = 1

-- Average speed of rockets. Note that ejectors and var thrust ramp up will
-- likely throw things off.
RocketSpeed = 65
