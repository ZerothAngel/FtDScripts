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

MissileProfiles = {
   -- First profile
   {
      -- What weapon slot to associate with. Should be 0-5, with 0 meaning
      -- the "all" slot.
      WeaponSlot = 1,
      -- Set to true to have the script fire this weapon slot itself.
      -- An LWC is not needed in that case. However, script-fired weapons
      -- aren't governed by failsafes, so keep that in mind...
      -- Missile controllers on turrets should be assigned the same weapon
      -- slot as their turret block.
      FireControl = false,
      -- Target selection algorithm for newly-launched missiles.
      -- 1 = Focus on highest priority target
      -- 2 = Pseudo-random split against all targetable targets
      TargetSelector = 1,
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
         -- For a more detailed explanation of what the following means,
         -- see my unifiedmissile script.
         SpecialAttackElevation = 10,
         MinimumAltitude = 0,
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
         SpecialManeuverDistance = 250,
         SpecialManeuverAboveSeaLevel = true,
         SpecialManeuverElevation = 3,
         SpecialManeuverAltitude = 30,
         SpecialManeuverAltitudeRelativeTo = 3,
         SpecialManeuverThrust = nil,
         SpecialManeuverThrustAngle = nil,
         TerminalDistance = 100,
         TerminalThrust = nil,
         TerminalThrustAngle = nil,
         LookAheadTime = 2,
         LookAheadResolution = 3,
      },
   },

   -- Second profile
   {
      WeaponSlot = 2,
      FireControl = false,
      TargetSelector = 1,
      BlockRange = 5,
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -500,
         MaxAltitude = 15,
      },
      -- Bottom-attack torpedoes
      Config = {
         SpecialAttackElevation = 9999, -- Always use special attack profile
         MinimumAltitude = -500,
         DefaultThrust = nil,
         DetonationRange = nil,
         DetonationAngle = 30,
         ClosingDistance = 50,
         ClosingAboveSeaLevel = false,
         ClosingElevation = 10, -- i.e. Minimum altitude above seabed
         ClosingAltitude = -50,
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
      },

   },

   -- You can add more profiles here.
   -- I recommended you copy & paste the first one and then edit to taste.
   -- PAY ATTENTION TO THE COMMAS
}

-- OTHER MISSILE CONFIG EXAMPLES

-- Just rename to "Config" and replace the appropriate section above.

-- Javelin-style top-attack profile
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

-- Sea-skimming pop-under missiles
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
