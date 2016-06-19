-- AVOIDANCE CONFIGURATION

-- How much clearance to require above and below when avoiding
-- terrain and friendlies.
-- Ship's height is multiplied by this and then centered around
-- the ship's physical midpoint (not necessarily the center of mass).
-- ClearanceFactor of 1 means to check exactly the ship's lower
-- and upper bounds.
-- Rotations (pitch, roll) are not accounted for, so it's best to
-- have some padding.
ClearanceFactor = 2

-- Distance to check for friendlies. Friendlies beyond this
-- distance are ignored.
FriendlyCheckDistance = 500
-- Each of the following has two numbers:
-- The first is a duration of time in seconds. If a collision
-- looks imminent within this time, it will turn away.
-- The second is the absolute minimum distance to be from friendlies.
FriendlyAvoidanceCombat = { 20, 100 }
FriendlyAvoidanceIdle = { 10, 100 }
-- Friendly avoidance weight. Generally should be >1.
-- Set to 0 to disable friendly avoidance.
-- Greater number means it will begin to turn away sooner.
FriendlyAvoidanceWeight = 10

-- Terrain avoidance settings
-- How many seconds ahead (at current speed) to sample
-- the terrain.
LookAheadTimes = { .25, 1, 2, 3, 5, 8, 13, 21 }
-- Bearings for sampling terrain. Note that the number
-- of look ahead times multiplied by the number of angles is
-- how many terrain samples it will check PER UPDATE. So keep
-- things reasonable.
LookAheadAngles = { -75, -60, -45, -30, -15, 0, 15, 30, 45, 60, 75 }
-- Terrain avoidance weight. Should be >1, set to 0 to disable.
-- Greater number means it will begin to turn away sooner.
TerrainAvoidanceWeight = 100
