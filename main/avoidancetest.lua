--! avoidancetest
--@ yawthrottle commons avoidance firstrun periodic
function AvoidanceTest_Update(I)
   YawThrottle_Reset()

   -- Just go as straight as possible
   AdjustHeading(Avoidance(I, 0))
end

AvoidanceTest = Periodic.create(UpdateRate, AvoidanceTest_Update)

function Update(I) -- luacheck: ignore 131
   if ActivateWhen[I.AIMode] then
      C = Commons.create(I)

      if FirstRun then FirstRun(I) end

      AvoidanceTest:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   end
end
