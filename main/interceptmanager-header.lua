-- CONFIGURATION

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

-- Range to fire interceptors
InterceptRange = 1000

-- Hostile missiles at or below this altitude are considered torpedoes
InterceptTorpedoBelow = 0

-- Weapon slots to fire for each quadrant and hostile missile type. Use nil for unassigned.
InterceptWeaponSlot = {
   Missile = {
      LeftRear = nil,
      LeftForward = nil,
      RightRear = nil,
      RightForward = nil,
   },
   Torpedo = {
      LeftRear = nil,
      LeftForward = nil,
      RightRear = nil,
      RightForward = nil,
   },
}
