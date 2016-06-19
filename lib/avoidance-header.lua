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
-- Will begin to turn away once it looks like a collision
-- will happen within this many seconds.
FriendlyAvoidanceTime = 20
-- Friendly avoidance weight. Generally should be >1.
-- Set to 0 to disable friendly avoidance.
-- Greater number means it will begin to turn away sooner.
FriendlyAvoidanceWeight = 1000

-- Terrain avoidance settings
-- How many seconds ahead (at current speed) to sample
-- the terrain.
LookAheadTimes = { .25, 5, 20 }
-- Relative bearings for sampling terrain. Note that the number
-- of look ahead times multiplied by the number of angles is
-- how many terrain samples it will check PER UPDATE. So keep
-- things reasonable.
LookAheadAngles = { -90, -45, -15, 0, 15, 45, 90 }
-- Terrain avoidance weight. Should be >1, set to 0 to disable.
-- Greater number means it will begin to turn away sooner.
TerrainAvoidanceWeight = 10000
