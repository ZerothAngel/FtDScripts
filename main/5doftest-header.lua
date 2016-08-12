-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
--   on = true,
   combat = true,
}

TestSteps = {
   {
      Offset = Vector3(0, 0, 1000),
      Heading = 90,
   },
   {
      Offset = Vector3(1000, 0, 0),
      Heading = 0,
   },
   {
      Offset = Vector3(0, 0, -1000),
      Heading = 270,
   },
   {
      Offset = Vector3(-1000, 0, 0),
      Heading = 180,
   },
}

StepDelay = 2400
