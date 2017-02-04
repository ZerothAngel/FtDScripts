-- DUAL PROFILE MISSILES

-- Altitude and range limits for each profile, used for target selection.
-- They should generally match the settings on the Local Weapon Controller
-- for each set of missile launchers.

-- It will prevent locking onto high-priority targets that are farther
-- than your missiles' max range or re-locking onto targets your missiles
-- can't hit (e.g. torpedoes re-locking onto air targets).
VerticalLimits = {
   MinRange = 0,
   MaxRange = 9999,
   MinAltitude = -25,
   MaxAltitude = 9999,
}

HorizontalLimits = {
   MinRange = 0,
   MaxRange = 9999,
   MinAltitude = -500,
   MaxAltitude = 15,
}

-- Optional weapon slot to fire. If non-nil then an LWC is not needed.
-- However, script-fired weapons aren't governed by failsafes, so keep
-- that in mind...
-- Missile controllers on turrets should be assigned the same weapon slot
-- as their turret block.
VerticalWeaponSlot = nil
HorizontalWeaponSlot = nil

-- Target selection algorithm for newly-launched missiles.
-- 1 = Focus on highest priority target
-- 2 = Pseudo-random split against all targetable targets
VerticalTargetSelector = 1
HorizontalTargetSelector = 1

-- PROFILE CONFIGURATION

-- One profile must be named "VerticalConfig" and another "HorizontalConfig"

-- The following defaults set up sea-skimming pop-up missiles for
-- vertical launch, bottom-attack torpedoes for horizontal launch.

-- See https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md for details about profile configuration.

-- VERTICAL MISSILE PROFILE

VerticalConfig = {
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
}

-- HORIZONTAL MISSILE PROFILE

HorizontalConfig = {
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
}
