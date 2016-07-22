-- CONFIGURATION

-- Set to true to control ship when AI set to "on" as well
ActivateWhenOn = false

MinDistance = 500
AttackDistance = 650
MaxDistance = 800

AttackAngle = 0
AttackPitch = -10
AttackEvasion = { 100, .5 }

ClosingAngle = 0
ClosingPitch = 0
ClosingEvasion = { 30, .25 }

EscapeAngle = 180
EscapePitch = 0
EscapeEvasion = { 30, .25 }

ReturnToOrigin = true
OriginMaxDistance = 250

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4
