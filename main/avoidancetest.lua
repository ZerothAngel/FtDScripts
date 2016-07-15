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
   if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      AvoidanceTest:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   end
end
