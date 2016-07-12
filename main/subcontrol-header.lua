-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true
ControlDepth = true

-- Desired depth for combat and out-of-combat.
-- First value is the desired depth/altitude.
-- Second value true/false indicating whether it is absolute (true) or
-- relative to terrain (false).
-- If relative, then first number is altitude above sea terrain.
-- Otherwise, it is depth below sea level (0).
DesiredDepthCombat = { 20, false }
DesiredDepthIdle = { 0, true }

-- Minimum depth.
-- Only valid when desired depth is relative.
MinDepth = 50

-- PID values for hydrofoils
-- Start with { 1, nil, 0 } and tune from there.
-- Setting Ti to nil eliminates integral component.
RollPIDValues = { .01, 40, .4 } -- { Kp, Ti, Td }
PitchPIDValues = { .1, 20, .5 } -- { Kp, Ti, Td }
DepthPIDValues = { 1, nil, 0 } -- { Kp, Ti, Td }

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4
