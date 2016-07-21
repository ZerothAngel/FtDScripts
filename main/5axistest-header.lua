-- CONFIGURATION

-- Set to true to control ship when AI set to "on" as well
ActivateWhenOn = false

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
