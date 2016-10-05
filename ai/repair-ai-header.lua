-- Offset from repair target's center of mass.
-- Note the Y value is ignored.
RepairTargetOffset = Vector3(0, 0, 25)

-- When considering other repair targets, they must
-- be within this distance and within this altitude range
RepairTargetMaxDistance = 1000
RepairTargetMaxParentDistance = 1000
RepairTargetMaxAltitudeDelta = 150
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
