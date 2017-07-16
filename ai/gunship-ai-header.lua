-- GUNSHIP AI

MinDistance = 500
AttackDistance = 650
MaxDistance = 800

AirTargetAboveAltitude = 50

AttackAngle = 0
AttackPitch = {
   Surface = -10,
   Air = 5,
}
AttackEvasion = { 100, .5 }
AttackLeadWeaponSlot = nil

ClosingAngle = 0
ClosingPitch = {
   Surface = 0,
   Air = 0,
}
ClosingEvasion = { 30, .25 }
ClosingLeadWeaponSlot = nil

EscapeAngle = 180
EscapePitch = {
   Surface = 0,
   Air = 0,
}
EscapeEvasion = { 30, .25 }
EscapeLeadWeaponSlot = nil

RelativePitch = {
   -- If enabled, the appropriate configured pitch (e.g. AttackPitch.Surface
   -- or AttackPitch.Air) is added to the elevation of the target and
   -- then constrained.
   Enabled = false,
   -- Constraints only used when Enabled = true
   MinPitch = -30,
   MaxPitch = 30,
}

ReturnToOrigin = true
OriginMaxDistance = 100
