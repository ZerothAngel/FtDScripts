--! target-ai
--@ commons control firstrun periodic
--@ sixdof ytdefaults target-ai
TargetAI = Periodic.create(UpdateRate, TargetAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         TargetAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         TargetAI_Reset()
         V.Reset()
      end

      SixDoF.Update(I)
   else
      TargetAI_Reset()
      SixDoF.Disable(I)
   end
end
