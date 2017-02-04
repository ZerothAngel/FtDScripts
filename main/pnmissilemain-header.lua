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
-- Optional weapon slot to fire. If non-nil then an LWC is not needed.
-- However, script-fired weapons aren't governed by failsafes, so keep
-- that in mind...
-- Missile controllers on turrets should be assigned the same weapon slot
-- as their turret block.
MissileWeaponSlot = nil

-- Target selection algorithm for newly-launched missiles.
-- 1 = Focus on highest priority target
-- 2 = Pseudo-random split against all targetable targets
MissileTargetSelector = 1

Config = {
   -- PN gain value
   -- 5 is generally good, will have to increase significantly for
   -- torpedoes (300-500)
   Gain = 5,

   -- If the missile is ever below this altitude, it will head straight up.
   -- Set to -500 or lower for torpedoes.
   MinimumAltitude = 0,

   -- Attempt one turn up to this many seconds from launch
   -- Set to nil to disable
   OneTurnTime = 3,
   -- Maximum one turn angle error, in degrees
   -- Set to nil to depend solely on time
   OneTurnAngle = 15,

   -- Detonate this many meters from aim point
   -- Set to nil to disable
   DetonationRange = nil,
   -- Detonate if angle error is greater than this, in degrees
   -- Set to nil to depend solely on range
   DetonationAngle = 30,

   -- Default thrust when not within terminal range
   DefaultThrust = nil,

   -- Range at which to set terminal thrust
   TerminalRange = nil,
   -- Thrust when within terminal range.
   -- Set to negative to base dynamically on (estimated) remaining fuel and
   -- time to impact.
   TerminalThrust = nil,
   -- Additional condition before modifying thrust.
   -- If non-nil, angle between missile velocity and target vector must
   -- be less than this.
   TerminalThrustAngle = nil,
}
