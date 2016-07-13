--! avoidancetest
--@ yawthrottle getselfinfo avoidance periodic
FirstRun = nil

function FirstRun(I)
   FirstRun = nil

   AvoidanceFirstRun(I)
end

function AvoidanceTest_Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      -- Just go as straight as possible
      AdjustHeading(I, Avoidance(I, 0))
   end
end

AvoidanceTest = Periodic.create(UpdateRate, AvoidanceTest_Update)

function Update(I)
   AvoidanceTest:Tick(I)
end
