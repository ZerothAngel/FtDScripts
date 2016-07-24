--! avoidancetest
--@ yawthrottle getselfinfo avoidance firstrun periodic
function AvoidanceTest_Update(I)
   YawThrottle_Reset()

   -- Just go as straight as possible
   AdjustHeading(Avoidance(I, 0))
end

AvoidanceTest = Periodic.create(UpdateRate, AvoidanceTest_Update)

function Update(I)
   if ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      AvoidanceTest:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   end
end
