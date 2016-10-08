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

-- Angle in degrees directly behind shield at which to deactivate that
-- shield. This basically defines a cone behind the shield and if enemies
-- can only be found in that cone, the shield will turn off.
-- Larger the angle, the more often the shield will turn off (and also
-- the more risk that something will get through).
-- 45 is conservative, 90 is probably the sane maximum.
ShieldOffAngle = 45

-- Delay in seconds before turning off a shield.
ShieldOffDelay = 3
