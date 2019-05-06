-- GUNSHIP AI

-- Target ranges that determine behavior, measured as ground distance.
-- If target distance < MinDistance, then use Escape settings.
-- If target distance > MaxDistance, then use Closing settings.
-- Otherwise use Attack settings, while trying to keep the vehicle at
-- AttackDistance at all times.
MinDistance = 500
AttackDistance = 650
MaxDistance = 800

-- Attack settings (MinDistance < target distance < MaxDistance)

-- Bearing angle at which to keep target. 0 = straight ahead, 180 = straight
-- behind. 90 = 90 degrees left or right side (will choose closest side)
AttackAngle = 0

-- Minimum & maximum pitch angles, relative to horizon.
-- First number is minimum pitch, 2nd is max.
AttackPitch = { -30, 30 }

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
ClosingPitch = { 0, 0 }
ClosingEvasion = { 30, .25 }
ClosingLeadWeaponSlot = nil

-- Escape settings (target distance < MinDistance)
EscapeAngle = 165
EscapePitch = { 0, 0 }
EscapeEvasion = { 30, .25 }
EscapeLeadWeaponSlot = nil

-- Set to true to return to the fleet waypoint/spawn location.
ReturnToFormation = true
-- Measured in meters, when closer than this to the fleet waypoint, it
-- will try to match the heading of the fleet flagship.
-- If this vehicle is the flagship, this represents how close
-- it will attempt to stay near the fleet waypoint.
MaxWanderDistance = 100
