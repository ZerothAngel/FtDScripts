-- MOBILE MINES

-- Generally these should match the settings on your Local Weapon Controller.
-- It will prevent locking onto high-priority targets that are farther
-- than your missiles' max range or re-locking onto targets your missiles
-- can't hit (e.g. torpedoes re-locking onto air targets).
MobileMineLimits = {
   MinRange = 0,
   MaxRange = 9999,
   MinAltitude = -500,
   MaxAltitude = 10,
}
-- Optional weapon slot to fire. If non-nil then an LWC is not needed.
-- However, script-fired weapons aren't governed by failsafes, so keep
-- that in mind...
-- Missile controllers on turrets should be assigned the same weapon slot
-- as their turret block.
MobileMineWeaponSlot = nil

-- Target selection algorithm for newly-launched missiles.
-- 1 = Focus on highest priority target
-- 2 = Pseudo-random split against all targetable targets
MobileMineTargetSelector = 1

MobileMineConfig = {
   -- Distance from target to impact water.
   -- Any short range thrusters will be disabled to ideally impact at this
   -- distance. However, air drag among other things will likely throw this
   -- off. Keep in mind that the missile will still have forward momentum
   -- once under water.
   DropDistance = 150,
   -- Minimum depth
   MinDepth = 5,
   -- Depth offset vs. aim point on nearest enemy
   DepthOffset = 0,
   -- Range for magnet when there are no friendlies around
   MagnetRange = 100,
   -- Shuts off magnet for nearby friendlies
   --   Only consider friendlies below this altitude
   --   (Mines near the surface can pull themselves up quite high, so be
   --   conservative.)
   MaxFriendlyAltitude = 50,
   --   And within this range
   MinFriendlyRange = 100,
}
