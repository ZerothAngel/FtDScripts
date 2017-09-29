-- CONFIGURATION

-- Generally these should match the settings on your Local Weapon Controller.
-- It will prevent locking onto high-priority targets that are farther
-- than your missiles' max range or re-locking onto targets your missiles
-- can't hit (e.g. torpedoes re-locking onto air targets).
Limits = {
   MinRange = 0,
   MaxRange = 9999,
   MinAltitude = -500,
   MaxAltitude = 9999,
}
-- Optional weapon slot to fire. If non-nil then an LWC is not needed.
-- However, script-fired weapons aren't governed by failsafes, so keep
-- that in mind...
-- Missile controllers on turrets should be assigned the same weapon slot
-- as their turret block.
MissileWeaponSlot = nil

-- Target selection algorithm for newly-launched missiles.
-- 1 = Focus on highest priority target
-- 2 = Pseudo-random split against all targetable targets
MissileTargetSelector = 1

-- Configuration for FakeTDC guidance
Config = {
   -- Number of seconds before guidance is disabled. Should be sufficiently
   -- long enough to account for turning radius & terminal velocity.
   -- How long to set this depends on your missile characteristics. Too long
   -- and it basically becomes a guided missile...
   OneTurnTime = 3,
   -- Whether or not this missile system fires torpedoes. If true, then it
   -- will only perform 2D aiming (i.e. same plane)
   IsTorpedo = true,
}
