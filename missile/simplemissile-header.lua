-- SIMPLE MISSILE CONFIGURATION

-- Two profiles are defined by default:
--   TopAttack
--   Torpedo

-- You must give each launcher one of the above names. You should also
-- give the same name to the associated Lua transceiver.

-- At the very least, be sure to tune the velocity/turn rates of
-- each profile for the types of missile you are using.

MissileProfiles = {
   -- First profile: Javelin-style missiles
   {
      SelectBy = { Name = "TopAttack", },
      -- If you don't have a weapon controller, set this to the missile
      -- controller's weapon slot.
      FireWeaponSlot = nil,
      -- 1 = Highest priority target
      -- 2 = Random target (per missile)
      TargetSelector = 1,
      -- If you have a weapon controller, these values should match its
      -- settings.
      -- If you don't have a weapon controller, then be sure to set these
      -- appropriately.
      Limits = {
         MinRange = 0,
         MaxRange = 9999,
         MinAltitude = -25,
         MaxAltitude = 9999,
      },
      Config = {
         -- If using a variable thruster, be sure to (temporarily)
         -- set it to CruiseThrust (see below) before updating the
         -- velocity and turn rate.

         -- Velocity of the missile in m/s as given by the stats screen.
         -- If there are multiple velocties, use the biggest one.
         Velocity = 155,
         -- Turn rate of the missile in deg/s.
         -- If there are multiple turn rates, use the smallest one.
         TurnRate = 31.4,

         -- Altitude to ascend to before cruising to target
         AscentAltitude = 300,
         -- Variable thrust setting during ascent and before reaching
         -- cruise distance.
         AscentThrust = 300,

         -- Variable thrust setting during cruise phase.
         CruiseThrust = 1000,
         -- Terminal distance is multiplied by this to get start of
         -- cruise distance.
         -- If set too high, your missiles won't ever reach
         -- AscendAltitude unless launched sufficiently far away.
         CruiseDistanceMultiplier = 2,

         -- Maximum difference from target bearing before changing
         -- terminal thrust.
         TerminalAngle = 5,
         -- Variable thrust during terminal phase.
         -- Set to -1 to have thrust determined automatically.
         -- It will use as much thrust as possible without running out of
         -- fuel before impact.
         TerminalThrust = -1,

         -- Targets this high (or higher) off the ground are considered
         -- air targets.
         AirElevation = 10,
         -- Variable thrust setting during standard air interception.
         AntiAirThrust = 1000,
      },
   },

   -- Second profile: Bottom-attack torpedoes
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
      Config = {
         -- Velocity of the torpedo in m/s as given by the stats screen.
         -- If there are multiple velocties, use the biggest one.
         Velocity = 66,
         -- Turn rate of the torpedo in deg/s.
         -- If there are multiple turn rates, use the smallest one.
         TurnRate = 30,

         -- Cruising depth of the torpedo.
         -- The torpedo will travel this many meters below the target
         -- aim point, hugging the sea bed as necessary.
         -- Should be a positive number.
         RelativeDepth = 50,
      },
   },

   -- You can copy & paste more profiles here, but make sure to give them
   -- different names.
}
