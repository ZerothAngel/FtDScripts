--! utilitysub
--@ commons firstrun periodic
--@ shieldmanager subcontrol sixdof depthcontrol ytdefaults utility-ai utility-aicommon
-- Utility submarine main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
DepthControl = Periodic.create(DepthControl_UpdateRate, Depth_Control, 1)
UtilityAI = Periodic.create(AI_UpdateRate, UtilityAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      DepthControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         UtilityAI_Reset()
         SixDoF_Reset()
      end

      Depth_Apply(I)
      SubControl_Update(I)
      SixDoF_Update(I)
   else
      UtilityAI_Reset()
      SixDoF_Disable(I)
   end

   ShieldManager:Tick(I)
end
