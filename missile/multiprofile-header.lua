-- MULTI PROFILE CONFIGURATION

-- Four pre-defined profiles:
--   TopAttack
--   Torpedo
--   PopUnder
--   GlideBomb

-- You must give each launcher one of the above names. You should also
-- give the same name to the associated Lua transceiver.

-- All profiles tuned for medium missiles with 10-12 segments.

MissileProfiles = {
   {
      SelectBy = { Name = "TopAttack", },
      FireWeaponSlot = nil,
      TargetSelector = 1,
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -25,
         MaxAltitude = 9999,
      },
      -- Javelin-style missiles
      Config = {
         Velocity = 155,
         TurnRate = 31.4,

         MinAltitude = 0,
         DetonationRange = nil,
         DetonationAngle = 30,
         LookAheadTime = 2,
         LookAheadResolution = 3,

         AirProfileElevation = 10,
         AntiAir = {
            Phases = {
               {
                  Change = { Thrust = 1000, },
               },
            },
         },

         Phases = {
            {
               Distance = function (MinTerminal) return MinTerminal(300) end,
               Change = { When = { Angle = 5, }, Thrust = -1, },
            },
            {
               Distance = function (MinTerminal) return MinTerminal(300) * 2 end,
               AboveSeaLevel = true,
               MinElevation = 3,
               Altitude = 0,
               RelativeTo = 4,
               Change = { Thrust = 1000, },
            },
            {
               Distance = 50,
               AboveSeaLevel = true,
               MinElevation = 3,
               Altitude = 300,
               RelativeTo = 0,
               Change = { Thrust = 300, },
            },
         },
      },
   },

   {
      SelectBy = { Name = "Torpedo", },
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
         Velocity = 66,
         TurnRate = 30,

         MinAltitude = -500,
         DetonationRange = 15,
         DetonationAngle = 30,
         LookAheadTime = 2,
         LookAheadResolution = 3,

         Phases = {
            {
               Distance = function (MinTerminal) return MinTerminal(50) end,
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

   {
      SelectBy = { Name = "PopUnder", },
      FireWeaponSlot = nil,
      TargetSelector = 1,
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -25,
         MaxAltitude = 9999,
      },
      -- Sea-skimming pop-under missiles
      Config = {
         MinAltitude = -50,
         DetonationRange = 5,
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
               Distance = 110,
            },
            {
               Distance = 270,
               AboveSeaLevel = false,
               MinElevation = 10,
               Altitude = -20,
               RelativeTo = 2,
            },
            {
               Distance = 470,
               AboveSeaLevel = true,
               MinElevation = 10,
            },
            {
               Distance = 50,
               AboveSeaLevel = true,
               MinElevation = 1.5,
            },
         },
      },
   },

   {
      SelectBy = { Name = "GlideBomb", },
      FireWeaponSlot = nil,
      TargetSelector = 1,
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -25,
         MaxAltitude = 9999,
      },
      -- Rocket-propelled glide bombs
      Config = {
         MinAltitude = 0,
         DetonationRange = nil,
         DetonationAngle = 30,
         LookAheadTime = 2,
         LookAheadResolution = 3,

         Phases = {
            {
               Distance = 650,
               Change = {
                  When = { AltitudeGT = 100, },
                  ThrustDuration = 0,
               },
            },
            {
               Distance = 50,
               AboveSeaLevel = true,
               MinElevation = 3,
               Altitude = 350,
               RelativeTo = 0,
            },
         },
      },
   },
}
