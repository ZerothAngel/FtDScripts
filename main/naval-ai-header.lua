-- CONFIGURATION

-- Set to true to control ship when AI set to "on" as well
ActivateWhenOn = false

-- Target ranges that determine behavior
MinDistance = 300
MaxDistance = 500

-- Attack behavior (MinDistance < target range < MaxDistance)
AttackAngle = 80
-- Drive fraction from -1 to 1. This script will probably only
-- work when moving forward, so always set >0
AttackDrive = 1
-- Evasion settings have two values:
-- The magnitude of evasive maneuvers, in degrees
-- And a time scale. Generally <1.0 works best,
-- smaller means slower.
-- Set to nil to disable, e.g. AttackEvasion = nil
AttackEvasion = { 10, .125 }

-- Closing behavior (target range > MaxDistance)
ClosingAngle = 40
ClosingDrive = 1
ClosingEvasion = { 30, .25 }

-- Escape behavior (target range < MinDistance)
EscapeAngle = 120
EscapeDrive = 1
EscapeEvasion = { 20, .25 }

-- Air raid evasion
-- Overrides current evasion settings when target is
-- above a certain altitude
AirRaidAboveAltitude = 50
AirRaidEvasion = { 40, .25 }

-- Return-to-origin settings
ReturnToOrigin = true
ReturnDrive = 0.5
-- Stops after getting within this distance of origin
-- Should be quite generous, depending on your ship's turning
-- radius.
OriginMaxDistance = 100

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4
