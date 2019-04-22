--! avoidancetest
--@ commons control avoidance firstrun periodic sixdof ytdefaults
function AvoidanceTest_Update(I)
   V.Reset()

   -- Just go as straight as possible
   V.AdjustHeading(Avoidance(I, 0))
end

AvoidanceTest = Periodic.new(UpdateRate, AvoidanceTest_Update)

SelectHeadingImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         AvoidanceTest:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      SixDoF.Disable(I)
   end
end
