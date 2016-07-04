-- CONFIGURATION

-- Set to true to control ship when AI set to "on" as well
ActivateWhenOn = false

-- Offset from repair target's center of mass.
-- Note the Y value is ignored.
RepairTargetOffset = Vector3(25, 0, 25)
-- If farther away than this, set throttle to ClosingDrive (below)
ApproachMaxDistance = 100
-- Throttle when distance from repair target is >ApproachMaxDistance
ClosingDrive = 1
-- Speed relative to target in meters per second when
-- within AppraochMaxDistance but behind the target
RelativeApproachSpeed = 1
-- Minimum speed in meters per second when within ApproachMaxDistance
-- Probably not a good idea for hydrofoil-based subs to stop
MinimumSpeed = 2
-- Constants for throttle PID, used when within ApproachMaxDistance
-- { 1, nil, 0 } is a good but rough starting point
ThrottlePIDValues = { .01, nil, .5 } -- Kp, Ti, Td

-- When considering other repair targets, they must
-- be within this distance and within this altitude range
RepairTargetMaxDistance = 1000
RepairTargetMaxParentDistance = 1000
RepairTargetMinAltitude = -10
RepairTargetMaxAltitude = 25
-- And have health equal to or below this fraction
RepairTargetMaxHealthFraction = 0.95
-- And have health equal to or above this fraction
RepairTargetMinHealthFraction = 0.25

-- Repair targets are scored according to
-- Distance * DistanceWeight + ParentDistance * ParentDistanceWeight +
--   Damage * DamageWeight
-- Where Distance is this ship's distance from the target
-- ParentDistance is the target's distance from the parent
-- Damage is 1.0 - HealthFraction
DistanceWeight = 0
ParentDistanceWeight = -0.02
DamageWeight = 100.0
-- Parent's score multiplied by this bonus (or penalty if <1)
ParentBonus = 1.1

-- Return-to-origin settings
ReturnToOrigin = false
ReturnDrive = 0.5
-- Stops after getting within this distance of origin
-- Should be quite generous, depending on your ship's turning
-- radius.
OriginMaxDistance = 100

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4
