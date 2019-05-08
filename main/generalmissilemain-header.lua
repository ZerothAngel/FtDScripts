-- If you only have a single missile system on your vehicle, this script
-- is fine. But if you have more than one (e.g. anti-air & torpedoes),
-- look at my "multiprofile" script instead. It's a wrapper around this one.

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

-- See https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md
Config = {
   MinAltitude = 0,
   DetonationRange = nil,
   DetonationAngle = 30,
   LookAheadTime = 2,
   LookAheadResolution = 3,

   AirProfileElevation = 10,
   AntiAir = {
      Phases = {
         {
         },
      },
   },

   Phases = {
      {
         -- Terminal phase
         Distance = 350,
         -- Uncomment the following (the "Change" line) to adjust variable
         -- thrusters for max burn once heading within 10 degrees of aim point.
         -- Recommend you set default thrust in other phases as well (see below).
--         Change = { When = { Angle = 10, }, Thrust = -1, },
      },
      {
         -- Middle phase: hold current altitude
         Distance = 650,
         AboveSeaLevel = true,
         MinElevation = 3,
         Altitude = 0,
         RelativeTo = 4,
         -- Uncomment the following to set default thrust to 300 (or whatever)
--         Change = { Thrust = 1000, },
      },
      {
         -- Closing phase: climb to 300m absolute
         Distance = 50,
         AboveSeaLevel = true,
         MinElevation = 3,
         Altitude = 300,
         RelativeTo = 0,
         -- Uncomment the following to set default thrust to 300 (or whatever)
--         Change = { Thrust = 300, },
      },
   },
}
