--! avoidancetest
--@ yawthrottle getselfinfo avoidance firstrun periodic
function AvoidanceTest_Update(I)
   YawThrottle_Reset()

   -- Just go as straight as possible
   AdjustHeading(Avoidance(I, 0))
end

AvoidanceTest = Periodic.create(UpdateRate, AvoidanceTest_Update)

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      AvoidanceTest:Tick(I)

      YawThrottle_Update(I)
   end
end
