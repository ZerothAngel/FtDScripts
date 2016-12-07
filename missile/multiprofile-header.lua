-- MULTI PROFILE CONFIGURATION

-- How it works:

-- Each Lua transceiver (and thus the missiles its launch pad fires)
-- are assigned a profile.

-- The profile is selected by looking for the closest missile controller
-- that matches the profile's WeaponSlot AND is within BlockRange meters.

-- If no profiles match (probably due to damage), the first profile
-- is selected.

-- If multiple profiles have the same WeaponSlot, then the last one wins.

-- The following sets up sea-skimming pop-up missiles for the missile
-- launcher(s) on weapon slot 1 and bottom-attack torpedoes for the missile
-- launcher(s) on weapon slot 2.

-- See https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md for details about profile configuration.

MissileProfiles = {
   -- First profile
   {
      -- What weapon slot to associate with. Should be 0-5, with 0 meaning
      -- the "all" slot.
      WeaponSlot = 1,
      -- Lua transceivers at most this far (in meters) from missile
      -- controllers assigned to the above weapon slot are considered
      -- part of this profile.
      -- Note that this does not follow ACB-style Manhattan distances.
      -- This is the actual "as the crow flies" distance.
      BlockRange = 5,
      -- These should generally match the Local Weapon Controller to
      -- avoid locking and re-locking on things too far or out of
      -- the missile's element. (e.g. torpedoes re-locking onto air targets)
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -25,
         MaxAltitude = 9999,
      },
      -- Sea-skimming pop-up missiles
      Config = {
         MinAltitude = 0,
         DetonationRange = nil,
         DetonationAngle = 30,
         LookAheadTime = 2,
         LookAheadResolution = 3,

         AntiAir = {
            DefaultThrust = nil,
            TerminalRange = nil,
            Thrust = nil,
            ThrustAngle = nil,
            OneTurnTime = 3,
            OneTurnAngle = 15,
            Gain = 5,
         },

         ProfileActivationElevation = 10,
         Phases = {
            {
               Distance = 100,
               Altitude = nil,
               RelativeTo = 1,
               Thrust = nil,
               ThrustAngle = nil,
            },
            {
               Distance = 250,
               AboveSeaLevel = true,
               MinElevation = 3,
               ApproachAngle = nil,
               Altitude = 30,
               RelativeTo = 3,
               Thrust = nil,
               ThrustAngle = nil,
               Evasion = nil,
            },
            {
               Distance = 50,
               AboveSeaLevel = true,
               MinElevation = 3,
               ApproachAngle = nil,
               Altitude = nil,
               RelativeTo = 0,
               Thrust = nil,
               ThrustAngle = nil,
               Evasion = { 20, .25 },
            },
         },
      },
   },

   -- Second profile
   {
      WeaponSlot = 2,
      BlockRange = 5,
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -500,
         MaxAltitude = 15,
      },
      -- Bottom-attack torpedoes
      Config = {
         MinAltitude = -500,
         DetonationRange = nil,
         DetonationAngle = 30,
         LookAheadTime = 2,
         LookAheadResolution = 3,

         Phases = {
            {
               Distance = 175,
               Altitude = nil,
               RelativeTo = 1,
               Thrust = nil,
               ThrustAngle = nil,
            },
            {
               Distance = 50,
               AboveSeaLevel = false,
               MinElevation = 10,
               ApproachAngle = nil,
               Altitude = -150,
               RelativeTo = 2,
               Thrust = nil,
               ThrustAngle = nil,
               Evasion = nil,
            },
         },
      },
   },

   -- You can add more profiles here.
   -- I recommended you copy & paste the first one and then edit to taste.
   -- PAY ATTENTION TO THE COMMAS
}
