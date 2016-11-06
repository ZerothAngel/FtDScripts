--! 5doftest
--@ getselfinfo firstrun eventdriver
--@ fivedof
FiveDoFTest = EventDriver.create()

function FiveDoFTest_FirstRun(I)
   FiveDoFTest:Schedule(0, FiveDoFTest_Update)
end
AddFirstRun(FiveDoFTest_FirstRun)

TestIndex = 0

function FiveDoFTest_Update(I)
   TestIndex = TestIndex + 1
   I:LogToHud(string.format("Test step #%d!", TestIndex))
   local TestStep = TestSteps[TestIndex]
   SetHeading(TestStep.Heading)
   AdjustPosition(TestStep.Offset)
   TestIndex = TestIndex % #TestSteps

   FiveDoFTest:Schedule(StepDelay, FiveDoFTest_Update)
end

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if ActivateWhen[I.AIMode] then
         FiveDoFTest:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         FiveDoF_Reset()
      end

      FiveDoF_Update(I)
   end
end
