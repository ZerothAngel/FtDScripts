--! target-ai
--@ commons control firstrun periodic
--@ sixdof ytdefaults target-ai
TargetAI = Periodic.new(UpdateRate, TargetAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         TargetAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         TargetAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      TargetAI_Reset()
      SixDoF.Disable(I)
   end
end
