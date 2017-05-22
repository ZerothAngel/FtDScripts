-- NAVAL AI

-- Target ranges that determine behavior
MinDistance = 300
MaxDistance = 500

-- Attack behavior (MinDistance < target range < MaxDistance)
-- All angles are relative to the target's bearing. So 0 heads
-- straight toward the target and 180 is straight away from it.
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

-- If set, it should be between MinDistance and MaxDistance.
-- Only applies when MinDistance < target range < MaxDistance.
-- To have any effect, AttackAngle should NOT be 90 degrees.
AttackDistance = nil
-- PID for adjusting AttackAngle when near AttackDistance.
-- Effective AttackAngle will be scaled between AttackAngle and
-- 180 - AttackAngle depending on output of PID.
AttackPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}

-- Closing behavior (target range > MaxDistance)
-- ClosingAngle should be <90 to actually close with the target.
ClosingAngle = 40
ClosingDrive = 1
ClosingEvasion = { 30, .25 }

-- Escape behavior (target range < MinDistance)
-- EscapeAngle should be >90 to actually head away from the target.
EscapeAngle = 120
EscapeDrive = 1
EscapeEvasion = { 20, .25 }

-- Air raid evasion
-- Overrides current evasion settings when target is
-- above a certain altitude
AirRaidAboveAltitude = 50
AirRaidEvasion = { 40, .25 }

-- Preferred side to face toward enemy.
-- 1 = Starboard (right)
-- -1 = Port (left)
-- nil = No preference (will pick closest side)
PreferredBroadside = nil

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

-- Normally the attack run is ended once MinDistance is reached.
-- However this setting ensures that at least this many seconds were spent
-- attacking (either normally or forced). Useful against faster targets...
-- I guess. For best results, should take into account the time it takes to
-- rotate to the proper angle.
MinAttackTime = 10

-- Return-to-origin settings
ReturnToOrigin = true
