--! target-ai
--@ commons firstrun periodic
--@ sixdof ytdefaults target-ai
TargetAI = Periodic.create(UpdateRate, TargetAI_Update)

Control_Reset = SixDoF_Reset

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
         SixDoF_Reset()
      end

      SixDoF_Update(I)
   else
      TargetAI_Reset()
      SixDoF_Disable(I)
   end
end