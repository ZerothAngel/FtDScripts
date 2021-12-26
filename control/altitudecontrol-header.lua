-- ALTITUDE CONTROL

-- Switch to manual altitude control on these AI modes. Valid keys are "Off",
-- "Manual", "Automatic", and "Fleet".
-- Only used when ManualAltitudeDriveMaintainerName below is non-nil.
ManualAltitudeWhen = {
   Off = true,
   Manual = true,
   Automatic = true,
   Fleet = true,
}

-- Manual altitude control (optional, default disabled)
-- Can be nil, "Secondary" or "Tertiary" (include quotes)
ManualAltitudeDrive = nil

-- Determines scaling for manual altitude control. -1.0 throttle on the
-- drive maintainer means MinManualAltitude, 1.0 throttle means
-- MaxManualAltitude.
-- Only used when ManualAltitudeDriveMaintainerName above is non-nil.
MinManualAltitude = 0
MaxManualAltitude = 400

-- If false, your desired altitudes are relative to
-- the ground (or sea level, if over water)
-- If true, then no terrain checking will be done.
AbsoluteAltitude = false

-- Desired altitudes
DesiredAltitudeCombat = 100
DesiredAltitudeIdle = 100

-- Delay in seconds before shifting to combat altitude. Useful if combat
-- altitude is lower than idle and when being released from a carrier.
DesiredAltitudeCombatDelay = 0

-- If non-nil, then for targets above this altitude, the desired
-- altitude will be set to the target's altitude plus MatchTargetOffset,
-- instead of DesiredAltitudeCombat above.
MatchTargetAboveAltitude = nil
MatchTargetOffset = 0

-- Minimum & maximum altitude when following terrain.
-- Only valid when AbsoluteAltitude is false.
-- This differs from the hard limits below in that it lets you specify
-- narrower constraints to give more leeway when dodging/evading.
TerrainMinAltitude = 0
TerrainMaxAltitude = 300

-- Enable vertical dodging of missiles (when combined AI supports it)
-- 0 - No dodging
-- 1 - Dodge as recommended by AI
-- 2 - Dodge in direction of most leeway
-- 3 - Always dodge upwards
-- 4 - Always dodge downwards
AltitudeDodgeMode = 1

-- Never go below this altitude after summing up desired altitude,
-- evasion, dodging, etc.
-- Default is to never go below sea level, which is a safe but
-- impractical default. You will probably want to set this higher.
-- If AbsoluteAltitude is false, then the terrain will be used instead,
-- if it is higher.
HardMinAltitude = 0
-- Altitude ceiling
HardMaxAltitude = 400

-- First number is altitude variation
-- Second is time scale, which should generally be <1.
-- Smaller is slower.
-- Set to nil to disable, e.g. AltitudeEvasion = nil
AltitudeEvasion = { 5, .25 }

-- Whether or not to apply the above evasion settings when under manual
-- control.
ManualEvasion = true
