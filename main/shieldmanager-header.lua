-- CONFIGURATION

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

-- Distance from enemies in meters at which to activate shields
ShieldActivationRange = 5000

-- Shield mode to use
-- 1 = Disrupt
-- 2 = Reflect
-- 3 = Laser?
ShieldActivationMode = 2

-- Angle in degrees from forward at which to activate.
-- 135 is conservative, 180 is active all the time (pointless, just use ACB then),
-- 90 is probably the sane minimum.
ShieldActivationAngle = 135

-- Delay in seconds before turning off a shield.
ShieldOffDelay = 3
