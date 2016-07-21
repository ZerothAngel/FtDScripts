--! 5axistest
--@ getselfinfo firstrun eventdriver
--@ fiveaxis
FiveAxisTest = EventDriver.create()

function FiveAxisTest_FirstRun(I)
   FiveAxisTest:Schedule(0, FiveAxisTest_Update)
end
AddFirstRun(FiveAxisTest_FirstRun)

TestIndex = 0

function FiveAxisTest_Update(I)
   TestIndex = TestIndex + 1
   I:LogToHud(string.format("Test step #%d!", TestIndex))
   local TestStep = TestSteps[TestIndex]
   SetHeading(TestStep.Heading)
   SetPositionOffset(TestStep.Offset)
   TestIndex = TestIndex % #TestSteps

   FiveAxisTest:Schedule(StepDelay, FiveAxisTest_Update)
end

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and AIMode ~= "off" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then
         FiveAxisTest:Tick(I)

         -- Suppress default AI
         if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end
      else
         FiveAxis_Reset()
      end

      FiveAxis_Update(I)
   end
end
