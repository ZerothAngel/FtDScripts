-- CONFIGURATION

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

-- Whether or not to guide missile interceptors or to simply assign them
GuideMissileInterceptors = true

-- Weapon slot to fire for missile interceptors
-- Set to nil if interceptors are fired some other way (e.g. ACB)
MissileInterceptorWeaponSlot = nil

-- Range to fire interceptors. Also determines max lock range.
MissileInterceptorRange = 1000
