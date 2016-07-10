-- JAVELIN SETTINGS

-- Only perform top-attack for targets below this altitude.
-- If above this altitude, intercept as normal.
JavelinAirTargetAltitude = 10

-- When closing on the target, this is the height (above the target)
-- to cruise at.
JavelinClosingHeight = 100

-- The maximum distance (on the ground) to travel toward the target
-- when attempting to reach the cruising height. Smaller = steeper ascent.
JavelinClosingDistance = 50

-- Evasion settings while closing
-- First number is magnitude of evasion in meters (to each side)
-- Second number is time scale, smaller is slower. <1 recommended.
-- Set whole thing to nil to disable, e.g. JavelinEvasion = nil
JavelinEvasion = { 20, .25 }

-- Within this ground distance, the missile will follow a simple
-- intercept course. Smaller = steeper descent. Make sure your
-- missile is actually maneuverable enough!
JavelinTerminalDistance = 150
