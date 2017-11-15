-- AVOIDANCE CONFIGURATION

-- How much clearance to require above and below when avoiding
-- terrain and friendlies.
-- Ship's height is multiplied by this and then centered around
-- the ship's physical midpoint (not necessarily the center of mass).
-- ClearanceFactor of 1 means to check exactly the ship's lower
-- and upper bounds.
-- Rotations (pitch, roll) are not accounted for, so it's best to
-- have some padding.
ClearanceFactor = 1.1

-- FRIENDLY AVOIDANCE

-- Distance to check for friendlies. Friendlies outside these distances
-- are ignored. The minimum distance is useful for ignoring docked ships.
FriendlyCheckMinDistance = 25
FriendlyCheckMaxDistance = 500

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

-- TERRAIN AVOIDANCE

-- How many seconds ahead (at current speed) to sample
-- the terrain.
-- At minimum, it should be the time it takes for your ship to
-- complete a 90-degree turn.
LookAheadTime = 20

-- Look-ahead resolution, in meters. The smaller it is, the more
-- samples of the terrain will be taken.
-- Probably shouldn't be larger than the length of your ship.
-- Set to nil to automatically use a quarter of your ship's length.
LookAheadResolution = nil

-- When there's an obstacle in front, this is how far (in degrees)
-- left and right to check for an opening. Should probably be <45
LookAheadAngle = 30

-- By default, the horizontal midpoint and both sides of the ship
-- (after accounting for ClearanceFactor) are extended forward
-- and used to check the terrain. If you have a particularly
-- wide ship, you may want to check more points. Use this to
-- increase the number of subdivisions between the midpoint and
-- the sides. Set to 0 for no extra points, 1 for 1 extra
-- between midpoint and side (so 2 additional total), etc.
-- Don't go too crazy, because it will increase the number of
-- terrain checks dramatically.
TerrainAvoidanceSubdivisions = 0

-- Terrain avoidance weight. Should be >1, set to 0 to disable.
-- Greater number means it will begin to turn away sooner.
TerrainAvoidanceWeight = 100
