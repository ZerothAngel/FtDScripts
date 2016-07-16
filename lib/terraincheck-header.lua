-- TERRAIN CHECKING

-- How many seconds to look ahead, in terms of velocity.
-- Generally depends on your maximum vertical speed. The slower you
-- move vertically, the farther you should look ahead.
-- However, if your normal AI has any sort of terrain checking, this
-- should probably look farther than it.
-- Set to nil to base dynamically on the current altitude/depth.
-- You should also make sure TerrainCheckVerticalSpeed is accurate
-- below.
TerrainCheckLookAheadTime = 30

-- Look-ahead resolution, in meters. The smaller it is, the more
-- samples of the terrain will be taken.
-- Probably shouldn't be larger than the length of your ship.
-- Set to nil to automatically use half your ship's length.
TerrainCheckResolution = nil

-- By default, the horizontal midpoint and both sides of the ship
-- are extended forward and used to check the terrain.
-- If you have a particularly wide ship, you may want to check
-- more points. Use this to increase the number of subdivisions
-- between the midpoint and the sides. Set to 0 for no extra
-- points, 1 for 1 extra between midpoint and side (so 2
-- additional total), etc. Don't go too crazy, because it will
-- increase the number of terrain checks dramatically.
TerrainCheckSubdivisions = 0

-- Maximum vertical speed. Only used when TerrainCheckLookAheadTime
-- above is nil.
-- Set to nil to determine dynamically.
-- If you know the performance characteristics of your ship, it's
-- recommended you set this rather than leave it to be determined.
-- The starting max vertical speed is 1 m/s, which will lead to
-- very far look ahead distances (until the actual vertical speed
-- is determined).
TerrainCheckMaxVerticalSpeed = nil

-- When determining look ahead time dynamically, the remaining altitude
-- (= max altitude - current altitude) is multiplied by this before
-- dividing by the max vertical speed.
-- Should be slightly >1 to provide a buffer.
TerrainCheckBufferFactor = 1.05
