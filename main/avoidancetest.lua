--! avoidancetest
--@ yawthrottle getselfinfo avoidance periodic
FirstRun = nil

function FirstRun(I)
   FirstRun = nil

   AvoidanceFirstRun(I)
end

function AvoidanceTest_Update(I)
   if FirstRun then FirstRun(I) end

   YawThrottle_Reset()

   -- Just go as straight as possible
   AdjustHeading(Avoidance(I, 0))
end

AvoidanceTest = Periodic.create(UpdateRate, AvoidanceTest_Update)

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      AvoidanceTest:Tick(I)

      YawThrottle_Update(I)
   end
end
