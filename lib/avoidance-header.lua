-- How much clearance to require above and below the
-- center of mass when avoiding terrain and friendlies.
-- Ship's height is multiplied by this. Should be >.5 with
-- .5 meaning check exactly the ship's height (not recommended)
ClearanceFactor = 3

-- Minimum distances for friendly avoidance
FriendlyMinDistanceCombat = 250
FriendlyMinDistanceIdle = 100
-- Friendly avoidance weight. Generally should be >1.
-- Set to 0 to disable friendly avoidance.
-- Greater number means it will begin to turn away sooner.
FriendlyAvoidanceWeight = 1000

-- Terrain avoidance settings
-- How many seconds ahead (at current speed) to sample
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
