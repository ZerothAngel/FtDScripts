--! avoidancetest
--@ commons avoidance firstrun periodic sixdof ytdefaults
function AvoidanceTest_Update(I)
   SixDoF_Reset()

   -- Just go as straight as possible
   AdjustHeading(Avoidance(I, 0))
end

AvoidanceTest = Periodic.create(UpdateRate, AvoidanceTest_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         AvoidanceTest:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      end

      SixDoF_Update(I)
   else
      SixDoF_Disable(I)
   end
end
