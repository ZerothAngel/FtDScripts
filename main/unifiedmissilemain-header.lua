-- CONFIGURATION

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
   -- If not using the special attack profile, it will intercept as normal.
   -- Set to like -999 to disable the special attack profile.
   -- Set it to like 9999 to always use the special attack profile.
   SpecialAttackElevation = 10,

   -- If the missile is ever below this altitude, it will head straight up.
   -- Set to -500 or lower for torpedoes.
   MinimumAltitude = 0,

   -- Note: "RelativeTo" parameters should be one of
   -- 0 - Absolute
   -- 1 - Relative to target's altitude
   -- 2 - Relative to target's sea depth
   -- 3 - Relative to target's ground

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

   -- Ground distance from target for terminal phase. During this phase,
   -- it will intercept the target as normal, i.e. aim straight for the
   -- predicted aim point.
   TerminalDistance = 100,

   -- TERRAIN HUGGING

   -- How many seconds at current speed to look-ahead
   LookAheadTime = 5,

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
   ClosingDistance = 50,
   ClosingAboveSeaLevel = true,
   ClosingElevation = 3,
   ClosingAltitude = 100,
   ClosingAltitudeRelativeTo = 3, -- i.e. relative to target's ground
   Evasion = { 20, .25 },
   SpecialManeuverDistance = nil, -- No special maneuver phase
   SpecialManeuverAboveSeaLevel = true,
   SpecialManeuverElevation = 3,
   SpecialManeuverAltitude = 30,
   SpecialManeuverAltitudeRelativeTo = 3,
   TerminalDistance = 150,
   LookAheadTime = 5,
   LookAheadResolution = 0, -- No need to look at terrain
}

-- Bottom-attack torpedoes
-- Change "TorpedoConfig" to simply "Config" to overwrite the
-- above settings.
TorpedoConfig = {
   SpecialAttackElevation = 9999, -- Always use special attack profile
   MinimumAltitude = -500,
   ClosingDistance = 50,
   ClosingAboveSeaLevel = false,
   ClosingElevation = 10, -- i.e. Minimum altitude above seabed
   ClosingAltitude = -150,
   ClosingAltitudeRelativeTo = 2, -- i.e. relative to target's depth, which is never more than 0
   Evasion = nil,
   SpecialManeuverDistance = nil, -- No special maneuver phase
   SpecialManeuverAboveSeaLevel = true,
   SpecialManeuverElevation = 3,
   SpecialManeuverAltitude = 30,
   SpecialManeuverAltitudeRelativeTo = 3,
   TerminalDistance = 150,
   LookAheadTime = 5,
   LookAheadResolution = 3,
}

-- Sea-skimming pop-under missiles
-- Change "PopUnderConfig" to simply "Config" to overwrite the
-- above settings.
-- Note that you will probably need at least 1 torpedo propeller and
-- a ballast tank to use these settings.
-- You might be able to forego both if you make the TerminalDistance and
-- SpecialManeuverDistance smaller, i.e. 50 and 75 respectively.
PopUnderConfig = {
   SpecialAttackElevation = 10,
   MinimumAltitude = -100, -- Should be lower than SpecialManeuverAltitude
   ClosingDistance = 50,
   ClosingAboveSeaLevel = true,
   ClosingElevation = 3,
   ClosingAltitude = nil,
   ClosingAltitudeRelativeTo = 0,
   Evasion = { 20, .25 },
   SpecialManeuverDistance = 250,
   SpecialManeuverAboveSeaLevel = false,
   SpecialManeuverElevation = 10,
   SpecialManeuverAltitude = -50,
   SpecialManeuverAltitudeRelativeTo = 2, -- i.e. 50 meters below target's depth
   TerminalDistance = 150,
   LookAheadTime = 5,
   LookAheadResolution = 3,
}
