-- SHIELD MANAGER

-- Distance from enemies in meters at which to activate shields
ShieldActivationRange = 5000

-- Shield mode to use
-- 1 = Disrupt
-- 2 = Reflect
-- 3 = Laser?
-- nil = Scale strength up or down instead of changing mode
ShieldActivationMode = 2

-- Angle in degrees from a shield's forward vector at which to activate.
-- 135 is conservative, 180 is active all the time (kinda pointless, but
-- saves on ACBs). 90 is probably the sane minimum.
ShieldActivationAngle = 135

-- Delay in seconds before turning off a shield.
ShieldOffDelay = 3
