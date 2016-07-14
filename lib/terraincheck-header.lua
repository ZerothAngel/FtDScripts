-- TERRAIN CHECKING

-- How many seconds to look ahead, in terms of velocity
-- You can have any number of points (within reason)
-- If you have terrain avoidance, the furthest point
-- should probably be farther than its look-ahead.
TerrainCheckLookAhead = { 1, 2, 3, 5, 8, 13, 21, 34 }

-- By default, the horizontal center and both sides of the ship
-- are extended forward and used to check the terrain.
-- If you have a particularly wide ship, you may want to check
-- more points. Use this to increase the number of subdivisions
-- between the center and the sides. Set to 0 for no extra
-- points, 1 for 1 extra between center and side (so 2
-- additional total), etc. Don't go too crazy, because it will
-- increase the number of terrain checks dramatically.
TerrainCheckSubdivisions = 0
