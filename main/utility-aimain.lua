--! utility-ai
--@ commons firstrun periodic
--@ sixdof utility-ai
UtilityAI = Periodic.create(UpdateRate, UtilityAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         SixDoF_Update(I)
      else
         UtilityAI_Reset()
      end
   else
      UtilityAI_Reset()
      SixDoF_Disable(I)
   end
end
