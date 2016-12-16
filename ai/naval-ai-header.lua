-- NAVAL AI

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

-- If true, the ship will perform attack runs and bounce between
-- MinDistance and MaxDistance.
-- "Closing" settings are used if target range > MaxDistance
-- "Attack" settings are used until MinDistance is reached
-- "Escape" settings are then used until MaxDistance is reached,
-- then the next attack run is started.
AttackRuns = false

-- Forces an attack run after this many seconds. For times when
-- the target is faster than your ship, so your ship won't be
-- stuck constantly trying to escape.
ForceAttackTime = 30

-- Return-to-origin settings
ReturnToOrigin = true
