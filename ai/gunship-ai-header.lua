-- GUNSHIP AI

-- Target ranges that determine behavior, measured as ground distance.
-- If target distance < MinDistance, then use Escape settings.
-- If target distance > MaxDistance, then use Closing settings.
-- Otherwise use Attack settings, while trying to keep the vehicle at
-- AttackDistance at all times.
MinDistance = 500
AttackDistance = 650
MaxDistance = 800

-- Targets above this elevation are considered air targets.
-- Measured from terrain beneath target or sea level.
AirTargetAboveElevation = 50

-- Attack settings (MinDistance < target distance < MaxDistance)
-- Bearing angle at which to keep target. 0 = straight ahead, 180 = straight
-- behind. 90 = 90 degrees left or right side (will choose closest side)
AttackAngle = 0
-- Pitch angles (relative to horizon) for surface or air targets. Also see
-- RelativePitch section below if you actually want to point the nose at the
-- target.
AttackPitch = {
   Surface = -10,
   Air = 5,
}
-- Lateral (side-to-side) evasion settings. First number is maximum lateral
-- distance in meters. Second number is a time scale which should generally be
-- < 1. Smaller means slower.
-- Set to nil to disable lateral evasion.
-- I recommend you disable all evasion when tuning PIDs.
AttackEvasion = { 100, .5 }
-- Weapon slot to use for leading the target, for fixed or non-turreted weapons.
-- If non-nil, then the script will use the weapon's speed + target
-- position and velocity to adjust the current heading appropriately.
-- Note that if set, the angle you set above will be ignored.
-- Only hull-mounted cannons or missiles are considered.
AttackLeadWeaponSlot = nil

-- Closing settings (target distance > MaxDistance)
ClosingAngle = 15
ClosingPitch = {
   Surface = 0,
   Air = 0,
}
ClosingEvasion = { 30, .25 }
ClosingLeadWeaponSlot = nil

-- Escape settings (target distance < MinDistance)
EscapeAngle = 165
EscapePitch = {
   Surface = 0,
   Air = 0,
}
EscapeEvasion = { 30, .25 }
EscapeLeadWeaponSlot = nil

RelativePitch = {
   -- If enabled, the appropriate configured pitch (e.g. AttackPitch.Surface
   -- or AttackPitch.Air) is added to the true elevation angle of the target
   -- and then constrained.
   Enabled = false,
   -- Constraints only used when Enabled = true
   MinPitch = -30,
   MaxPitch = 30,
}

-- Set to true to return to the fleet waypoint/spawn location.
ReturnToOrigin = true
-- Measured in meters, when closer than this to the fleet waypoint, it
-- will try to match the heading of the fleet flagship.
-- If this vehicle is the flagship, this represents how close
-- it will attempt to stay near the fleet waypoint.
OriginMaxDistance = 100
