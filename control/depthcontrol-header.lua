-- DEPTH CONTROL

-- Switch to manual depth control on these AI modes. Valid keys are "Off",
-- "Manual", "Automatic", and "Fleet".
-- Only used when ManualDepthDriveMaintainerName below is non-nil.
ManualDepthWhen = {
   Off = true,
   Manual = true,
   Automatic = true,
   Fleet = true,
}

-- Manual depth control (optional, default disabled)
-- Positive drive means relative to sea floor: 0 = 500m above sea floor,
--   1 = 0m above sea floor (not recommended)
-- Negative drive corresponds to absolute depth: 0 = 0m, -1 = -500m
-- Can be nil, "Secondary" or "Tertiary" (include quotes)
-- Set to nil to use the configured depth settings (below).
ManualDepthDrive = nil

-- Desired depths for combat and out-of-combat.
-- First value is the desired depth or elevation and should always be
-- positive.
-- Second value is true/false indicating whether it is absolute (true) or
-- relative to terrain (false).
-- If relative, then first number is elevation above sea terrain.
-- Otherwise, it is depth below sea level (0).
DesiredDepthCombat = {
   Depth = 20,
   Absolute = false
}
DesiredDepthIdle = {
   Depth = 0,
   Absolute = true
}

-- Minimum & maximum depth when following terrain.
-- Only valid when desired depth is relative.
-- Should be 0 or positive.
-- This differs from the hard limits below in that it lets you specify
-- narrower constraints to give more leeway when dodging/evading.
TerrainMinDepth = 50
TerrainMaxDepth = 500

-- Enable vertical dodging of torpedoes (when combined AI supports it)
-- 0 - No dodging
-- 1 - Dodge as recommended by AI
-- 2 - Dodge in direction of most leeway
-- 3 - Always dodge upwards
-- 4 - Always dodge downwards
DepthDodgeMode = 0

-- Hard constraints on depth after summing up desired depth, dodging,
-- evasion, etc. These are absolute depth values.
HardMinDepth = 0
HardMaxDepth = 500

-- First number is depth variation
-- Second is time scale, which should generally be <1.
-- Smaller is slower.
-- Set to nil to disable, e.g. DepthEvasion = nil
DepthEvasion = nil

-- Whether or not to apply the above evasion settings when under manual
-- control.
ManualEvasion = true
