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

Config = {
   -- PN gain value
   Gain = 5,

   -- Attempt one turn up to this many seconds from launch
   -- Set to negative to disable
   OneTurnTime = 3,
   -- Maximum angle error, in degrees
   OneTurnAngle = 15,

   -- Detonate this many meters from aim point
   -- Set to negative to disable
   DetonationRange = 5,
   -- Detonate if angle error is greater than this, in degrees
   -- Set to 0 to depend solely on range
   DetonationAngle = 30,
}
