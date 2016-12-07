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

-- NOTE: The following config is for sea-skimming "pop-up" missiles.
-- There are more examples below it, including:
--  Javelin-style top-attack
--  Bottom-attack torpedoes
--  Sea-skimming pop-under missiles

-- Always be sure each setting ends with a comma!

Config = {
   -- GENERAL SETTINGS

   -- If the target's elevation (that is, altitude relative to the ground
   -- it is over) is below this, use the special attack profile (closing,
   -- special maneuver, etc.).
   -- Note that the "ground" is capped at 0 (sea level), so keep this in
   -- mind for submarine targets. Their elevation will always be negative.
   -- If not using the special attack profile, it will intercept as normal.
   -- Set to like -999 to disable the special attack profile.
   -- Set it to like 9999 to always use the special attack profile.
   SpecialAttackElevation = 10,

   -- If the missile is ever below this altitude, it will head straight up.
   -- Set to -500 or lower for torpedoes.
   MinimumAltitude = 0,

   -- Thrust to use in AA mode, may be nil.
   DefaultThrust = nil,

   -- Optional detonation range in meters -- to simulate a proximity fuse
   -- Set to negative or nil to disable.
   DetonationRange = nil,

   -- If a detonation range is defined, and the angle between the missile
   -- velocity and the target vector is greater than this, detonate.
   -- This allows detonations on near misses, i.e. when the missile is
   -- about to pass the aim point.
   -- Set to 0 to base detonation solely on range.
   DetonationAngle = 30,

   -- Note: "RelativeTo" parameters should be one of
   -- 0 - Absolute
   -- 1 - Relative to target's altitude
   -- 2 - Relative to target's sea depth
   -- 3 - Relative to target's ground
   -- 4 - Relative to missile's altitude

   -- SPECIAL ATTACK PROFILE

   -- The missile can have up to 3 phases: closing, special maneuver, terminal.
   -- To disable the special maneuver phase, set SpecialManeuverDistance
   -- to nil.

   -- Distance to aim toward target when closing.
   -- Smaller means it will reach closing elevation/altitude sooner,
   -- but will need to make a steeper angle to do so.
   ClosingDistance = 50,

   -- Whether the closing phase takes place above or below sea level.
   -- This affects terrain hugging.
   ClosingAboveSeaLevel = true,

   -- Minimum distance above terrain (or sea level).
   ClosingElevation = 3,

   -- Closing altitude. Set to nil to only hug terrain.
   -- If set to a number, you should also set ClosingAltitudeRelativeTo.
   ClosingAltitude = nil,

   -- See the "RelativeTo" explanation above. Only used if ClosingAltitude
   -- is a number and not nil.
   ClosingAltitudeRelativeTo = 0,

   -- Closing phase thrust setting for variable thrusters. nil to disable.
   ClosingThrust = nil,

   -- Maximum angle between target & missile velocity in degrees before
   -- modifying thrust. nil to set thrust regardless of angle.
   ClosingThrustAngle = nil,

   -- "Evasion" settings while closing
   -- This simply makes the missile move side-to-side in a pseudo-random
   -- manner.
   -- First number is magnitude of evasion in meters (to each side)
   -- Second number is time scale, smaller is slower. <1 recommended.
   -- Set whole thing to nil to disable, e.g. Evasion = nil
   Evasion = { 20, .25 },

   -- Ground distance from target at which to perform the special maneuver.
   -- Set to nil to disable.
   SpecialManeuverDistance = 250,

   -- Whether the special maneuver phase takes place above or below sea level.
   -- This affects terrain hugging.
   SpecialManeuverAboveSeaLevel = true,

   -- Minimum distance above terrain (or sea level)
   SpecialManeuverElevation = 3,

   -- Special maneuver altitude. Set to nil to only hug terrain.
   SpecialManeuverAltitude = 30,

   -- See the "RelativeTo" explanation above. Only used if
   -- SpecialManeuverAltitude is a number and not nil.
   SpecialManeuverAltitudeRelativeTo = 3,

   -- Special maneuver phase thrust setting for variable thrusters.
   -- nil to disable.
   SpecialManeuverThrust = nil,

   -- Maximum angle between target & missile velocity in degrees before
   -- modifying thrust. nil to set thrust regardless of angle.
   SpecialManeuverThrustAngle = nil,

   -- Ground distance from target for terminal phase. During this phase,
   -- it will intercept the target as normal, i.e. aim straight for the
   -- predicted aim point.
   TerminalDistance = 100,

   -- Terminal phase thrust setting for variable thrusters. nil to disable.
   TerminalThrust = nil,

   -- Maximum angle between target & missile velocity in degrees before
   -- modifying thrust. nil to set thrust regardless of angle.
   TerminalThrustAngle = nil,

   -- TERRAIN HUGGING

   -- How many seconds at current speed to look-ahead
   LookAheadTime = 2,

   -- Look-ahead resolution in meters. The smaller it is, the more samples
   -- will be taken (and more processing...)
   -- Set to 0 to disable terrain hugging, in which case the "ground"
   -- will always be assumed to be -500 or 0 (depending on the related
   -- sea level setting)
   LookAheadResolution = 3,
}

-- Javelin-style top-attack profile
-- Change "JavelinConfig" to simply "Config" to overwrite the
-- above settings.
JavelinConfig = {
   SpecialAttackElevation = 10,
   MinimumAltitude = 0,
   DefaultThrust = nil,
   DetonationRange = nil,
   DetonationAngle = 30,
   ClosingDistance = 50,
   ClosingAboveSeaLevel = true,
   ClosingElevation = 3,
   ClosingAltitude = 100,
   ClosingAltitudeRelativeTo = 3, -- i.e. relative to target's ground
   ClosingThrust = nil,
   ClosingThrustAngle = nil,
   Evasion = { 20, .25 },
   SpecialManeuverDistance = nil, -- No special maneuver phase
   SpecialManeuverAboveSeaLevel = true,
   SpecialManeuverElevation = 3,
   SpecialManeuverAltitude = 30,
   SpecialManeuverAltitudeRelativeTo = 3,
   SpecialManeuverThrust = nil,
   SpecialManeuverThrustAngle = nil,
   TerminalDistance = 150,
   TerminalThrust = nil,
   TerminalThrustAngle = nil,
   LookAheadTime = 2,
   LookAheadResolution = 0, -- No need to look at terrain
}

-- Bottom-attack torpedoes
-- Change "TorpedoConfig" to simply "Config" to overwrite the
-- above settings.
TorpedoConfig = {
   SpecialAttackElevation = 9999, -- Always use special attack profile
   MinimumAltitude = -500,
   DefaultThrust = nil,
   DetonationRange = nil,
   DetonationAngle = 30,
   ClosingDistance = 50,
   ClosingAboveSeaLevel = false,
   ClosingElevation = 10, -- i.e. Minimum altitude above seabed
   ClosingAltitude = -150,
   ClosingAltitudeRelativeTo = 2, -- i.e. relative to target's depth, which is never more than 0
   ClosingThrust = nil,
   ClosingThrustAngle = nil,
   Evasion = nil,
   SpecialManeuverDistance = nil, -- No special maneuver phase
   SpecialManeuverAboveSeaLevel = true,
   SpecialManeuverElevation = 3,
   SpecialManeuverAltitude = 30,
   SpecialManeuverAltitudeRelativeTo = 3,
   SpecialManeuverThrust = nil,
   SpecialManeuverThrustAngle = nil,
   TerminalDistance = 175,
   TerminalThrust = nil,
   TerminalThrustAngle = nil,
   LookAheadTime = 2,
   LookAheadResolution = 3,
}

-- Sea-skimming pop-under missiles
-- Change "PopUnderConfig" to simply "Config" to overwrite the
-- above settings.
-- Needs a lot of experimentation, but the following settings
-- work for me using 6-block missiles: Fin x3, Var thruster (300 thrust),
-- Torpedo prop, Fuel x2, Lua receiver, Warhead x4.
PopUnderConfig = {
   SpecialAttackElevation = 10,
   MinimumAltitude = -50, -- Should be lower than SpecialManeuverAltitude
   DefaultThrust = nil,
   DetonationRange = nil,
   DetonationAngle = 30,
   ClosingDistance = 50,
   ClosingAboveSeaLevel = true,
   ClosingElevation = 3,
   ClosingAltitude = nil,
   ClosingAltitudeRelativeTo = 0,
   ClosingThrust = nil,
   ClosingThrustAngle = nil,
   Evasion = { 20, .25 },
   SpecialManeuverDistance = 110,
   SpecialManeuverAboveSeaLevel = false,
   SpecialManeuverElevation = 10,
   SpecialManeuverAltitude = -25,
   SpecialManeuverAltitudeRelativeTo = 2, -- i.e. 25 meters below target's depth
   SpecialManeuverThrust = nil,
   SpecialManeuverThrustAngle = nil,
   TerminalDistance = 50,
   TerminalThrust = nil,
   TerminalThrustAngle = nil,
   LookAheadTime = 2,
   LookAheadResolution = 3,
}
