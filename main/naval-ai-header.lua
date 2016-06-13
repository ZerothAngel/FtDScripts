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

-- How much clearance to require above and below when
-- avoiding terrain and friendlies.
-- Ship's height is multiplied by this.
ClearanceFactor = 3

-- Minimum distances for friendly avoidance
FriendlyMinDistanceCombat = 250
FriendlyMinDistanceIdle = 100
-- Friendly avoidance weight. Generally should be >1.
-- Set to 0 to disable friendly avoidance.
-- Greater number means it will begin to turn away sooner.
FriendlyAvoidanceWeight = 100

-- Terrain avoidance settings
-- How many seconds ahead (at current velocity) to sample
-- the terrain.
LookAheadTimes = { 1, 5, 10 }
-- Relative bearings for sampling terrain. Note that the number
-- of look ahead times multiplied by the number of angles is
-- how many terrain samples it will check PER UPDATE. So keep
-- things reasonable.
LookAheadAngles = { -90, -45, -15, 0, 15, 45, 90 }
-- Terrain avoidance weight. Should be >1, set to 0 to disable.
-- Greater number means it will begin to turn away sooner.
TerrainAvoidanceWeight = 10000

-- Yaw PID controller settings
-- These default values have worked well for me on
-- a variety of ships. YMMV.
-- { 1.0, 0, 0 } is a good (but rough) starting point.
YawPIDValues = { 0.25, 0.0, 0.1 } -- P, I, D

-- Return-to-origin settings
ReturnToOrigin = true
ReturnDrive = 0.5
-- Stops after getting within this distance of origin
-- Should be quite generous, depending on your ship's turning
-- radius.
OriginMaxDistance = 100
