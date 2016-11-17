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

-- See https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md
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
}