-- BOTTOM ATTACK SETTINGS

-- Depth to cruise at when closing in on target. This is relative
-- to the target, so 30 would be 30 meters below the target.
-- Note that the target's altitude is clamped to a maximum of 0.
CruisingDepth = 150

-- Maximum distance to travel to reach cruising depth.
CruisingDistance = 50

-- Once reaching this ground distance from the target, it will head
-- straight for the aim point (ammo, AI, etc.)
TerminalDistance = 150

-- SEABED AVOIDANCE

-- Resolution, in meters, when looking ahead for seabed avoidance.
-- The smaller the resolution, the more samples will be taken.
BA_LookAheadResolution = 3

-- Number of seconds to look ahead at current speed for seabed avoidance.
LookAheadTime = 5

-- Minimum height to stay above the seabed
MinimumSeabedAltitude = 10
