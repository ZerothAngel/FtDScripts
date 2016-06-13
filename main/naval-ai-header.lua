-- Configuration
MinDistance = 300
MaxDistance = 500

AttackAngle = 80
-- Drive fraction from -1 to 1
AttackDrive = 1
-- Degrees, time scale (smaller = slower)
-- Set to nil to disable
AttackEvasion = { 10, .125 }

ClosingAngle = 40
ClosingDrive = 1
ClosingEvasion = { 30, .25 }

EscapeAngle = 120
EscapeDrive = 1
EscapeEvasion = { 20, .25 }

AirRaidAboveAltitude = 50
AirRaidEvasion = { 40, .25 }

ClearanceFactor = 3

FriendlyMinDistanceCombat = 250
FriendlyMinDistanceIdle = 100
FriendlyAvoidanceWeight = 100

LookAheadTimes = { 1, 5, 10 }
LookAheadAngles = { -90, -45, -15, 0, 15, 45, 90 }
TerrainAvoidanceWeight = 10000

YawPIDValues = { 0.25, 0.0, 0.1 } -- P, I, D

ReturnToOrigin = true
ReturnDrive = 0.5
OriginMaxDistance = 100

ActivateWhenOn = false
