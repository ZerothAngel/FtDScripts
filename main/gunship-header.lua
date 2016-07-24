-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
--   on = true,
   combat = true,
   patrol = true,
   fleetmove = true,
}

MinDistance = 500
AttackDistance = 650
MaxDistance = 800

AirTargetAboveAltitude = 50

AttackAngle = 0
AttackPitch = {
   Surface = -10,
   Air = 5,
}
AttackEvasion = { 100, .5 }

ClosingAngle = 0
ClosingPitch = {
   Surface = 0,
   Air = 0,
}
ClosingEvasion = { 30, .25 }

EscapeAngle = 180
EscapePitch = {
   Surface = 0,
   Air = 0,
}
EscapeEvasion = { 30, .25 }

ReturnToOrigin = true
OriginMaxDistance = 100

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4
