-- CRUISE MISSILE AI

CruiseMissileConfig = {
   -- Target selection
   MinTargetAltitude = -10,

   -- Detonation behavior
   ArmingRange = 200,
   DetonationRange = 20,
   DetonationDecel = 15,
   DetonationKey = nil,

   -- Terminal phase
   Gain = 3,
   TerminalDistance = 500,
   TerminalThrottle = 1,
   TerminalKey = nil,

   -- Middle (pop-up, etc.) phase
   MiddleDistance = nil,
   MiddleAltitude = 150,
   MiddleThrottle = 1,
   MiddleKey = nil,

   -- Closing (cruise) phase
   CruiseAltitude = 50,
   CruiseThrottle = 1,
   CruiseEvasion = { 10, .125 },
   CruiseKey = nil,
}

-- Return-to-origin settings
ReturnToOrigin = true
