-- CONFIGURATION

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
UpdateRate = 4

SteamRegulatorConfig = {
   Name = "MySteam",
   TargetLevel = .9,
   MaxBurnRate = .1,
   PIDConfig = {
      Kp = 3,
      Ti = 100,
      Td = 1.5,
   },
}
