-- Desired depth for combat and out-of-combat.
-- First value is the desired depth/altitude.
-- Second value true/false indicating whether it is absolute (true) or
-- relative to terrain (false).
-- If relative, then first number is altitude above sea terrain.
-- Otherwise, it is depth below sea level (0).
DesiredDepthCombat = { 15, false }
DesiredDepthIdle = { 0, true }

-- Minimum depth.
-- Only valid when desired depth is relative.
MinDepth = 30

-- PID values for hydrofoils
-- Start with { 1, nil, 0 } and tune from there.
-- Setting Ti to nil eliminates integral component.
HydrofoilPIDValues = { 1, nil, 0 } -- Kp, Ti, Td
