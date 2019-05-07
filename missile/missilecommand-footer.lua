-- MISSILE CONSTANTS

-- luacheck: push ignore 131
MissileConst_VarThrust = "Variable Thruster"
MissileConst_FuelTank = "Fuel Tank"
MissileConst_FuelAmount = 10000
MissileConst_Regulator = "Regulator"
MissileConst_LifetimeStart = 20 -- Is this really constant?
MissileConst_LifetimeAdd = 20
MissileConst_ShortRange = "Short Range Thruster"
MissileConst_ShortRangeFuelRate = 6000
MissileConst_Magnet = "Magnet (for mines)"
MissileConst_BallastTank = "Ballast Tanks"

MissileUpdateData = {
   {
      MissileConst_VarThrust,
      {
         VarThrust = { 2, 300, 3000 },
      },
   },
   {
      MissileConst_ShortRange,
      {
         ThrustDelay = { 1, 0, 20 },
         ThrustDuration = { 2, .1, 5 },
      },
   },
   {
      MissileConst_Magnet,
      {
         MagnetRange = { 1, 5, 200 },
         MagnetDelay = { 2, 3, 30 },
      },
   },
   {
      MissileConst_BallastTank,
      {
         BallastDepth = { 1, 0, 500 },
         BallastBuoyancy = { 2, -.5, .5 },
      },
   },
}
-- luacheck: pop
