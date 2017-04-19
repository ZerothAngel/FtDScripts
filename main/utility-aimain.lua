--! utility-ai
--@ commons firstrun periodic
--@ sixdof ytdefaults utility-ai
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
      else
         UtilityAI_Reset()
         SixDoF_Reset()
      end

      SixDoF_Update(I)
   else
      UtilityAI_Reset()
      SixDoF_Disable(I)
   end
end
