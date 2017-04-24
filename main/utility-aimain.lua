--! utility-ai
--@ commons control firstrun periodic
--@ sixdof ytdefaults utility-ai utility-aicommon
UtilityAI = Periodic.create(UpdateRate, UtilityAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         UtilityAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      UtilityAI_Reset()
      SixDoF.Disable(I)
   end
end
