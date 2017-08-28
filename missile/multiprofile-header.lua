-- MULTI PROFILE CONFIGURATION

-- Also see https://github.com/ZerothAngel/FtDScripts/blob/master/missile/multiprofile.md

-- How it works:

-- Each profile can select Lua transceivers in one of three ways:
--   By launcher orientation (vertical, horizontal)
--   By launcher direction (right, left, up, down, forward, back)
--   By weapon slot of the missile controller within a given distance

-- If a Lua transceiver potentially matches multiple profiles, then:
--   1. A matching profile that uses weapon slot/distance selection
--      always wins
--   2. Otherwise the first matching profile (going down the list)
--      will be used

-- If a Lua transceiver matches no profiles (due to damage or
-- misconfiguration), then the 1st profile is used.

-- Remember that subconstructs (turrets, spinners) have their own axes
-- independent of the main vehicle. This may make selection by
-- orientation/direction surprising(!).

-- See https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md for details about generalmissile configuration (the "Config" sections).

MissileProfiles = {
   -- First profile
   {
      -- How Lua transceivers are selected for this profile.
      -- You must only have one "SelectBy" expression.
      -- Comment out or delete the rest.
      SelectBy = {
         -- By orientation: true = vertical, false = horizontal
         Vertical = true,
      },
--      SelectBy = {
--         -- By launcher direction. Set Direction to a list of Vector3.<dir>
--         -- where <dir> is back, down, forward, left, right, up
--         -- Note that it must be a list even with a single direction.
--         Direction = { Vector3.left, Vector3.right },
--      },
--      SelectBy = {
--         -- By weapon slot of the closest missile controller
--         -- within a set (straight-line) distance
--         WeaponSlot = 1,
--         Distance = 5,
--      },
      -- Set to a number 1-5 to have the script fire this weapon slot itself.
      -- An LWC is not needed in that case. However, script-fired weapons
      -- aren't governed by failsafes, so keep that in mind...
      -- Missile controllers on turrets should be assigned the same weapon
      -- slot as their turret block.
      FireWeaponSlot = nil,
      -- Target selection algorithm for newly-launched missiles.
      -- 1 = Focus on highest priority target
      -- 2 = Pseudo-random split against all targetable targets
      TargetSelector = 1,
      -- These should generally match the Local Weapon Controller to
      -- avoid locking and re-locking on things too far or out of
      -- the missile's element. (e.g. torpedoes re-locking onto air targets)
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -25,
         MaxAltitude = 9999,
      },
      -- Javelin-style missiles
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
               Distance = 150,
            },
            {
               Distance = 500,
               AboveSeaLevel = true,
               MinElevation = 3,
               Altitude = 0,
               RelativeTo = 4,
            },
            {
               Distance = 50,
               AboveSeaLevel = true,
               MinElevation = 3,
               Altitude = 300,
               RelativeTo = 3,
            },
         },
      },
   },

   -- Second profile
   {
      SelectBy = { Vertical = false, }, -- Horizontal
      FireWeaponSlot = nil,
      TargetSelector = 1,
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -500,
         MaxAltitude = 15,
      },
      -- Bottom-attack torpedoes
      Config = {
         MinAltitude = -500,
         DetonationRange = 15,
         DetonationAngle = 30,
         LookAheadTime = 2,
         LookAheadResolution = 3,

         Phases = {
            {
               Distance = 175,
               Altitude = 0,
               RelativeTo = 6,
            },
            {
               Distance = 50,
               AboveSeaLevel = false,
               MinElevation = 10,
               Altitude = -50,
               RelativeTo = 2,
            },
         },
      },
   },

   -- You can add more profiles here.
   -- I recommended you copy & paste the first one and then edit to taste.
   -- PAY ATTENTION TO THE COMMAS
}
