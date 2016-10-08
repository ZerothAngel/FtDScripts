-- CONFIGURATION

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

-- Range to fire interceptors
InterceptRange = 1000

-- Weapon slots to fire for each octant. Use nil for unassigned.
DirectionalWeaponSlot = {
   LeftLowerRear = nil,
   LeftLowerForward = nil,
   LeftUpperRear = nil,
   LeftUpperForward = nil,
   RightLowerRear = nil,
   RightLowerForward = nil,
   RightUpperRear = nil,
   RightUpperForward = nil,
}
