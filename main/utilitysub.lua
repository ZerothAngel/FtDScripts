--! utilitysub
--@ commons firstrun periodic
--@ subcontrol depthcontrol yawthrottle utility-ai
-- Utility submarine main
SubControl = Periodic.create(SubControl_UpdateRate, Depth_Control, 1)
UtilityAI = Periodic.create(AI_UpdateRate, UtilityAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      SubControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         UtilityAI_Reset()
      end

      Depth_Apply(I)
      SubControl_Update(I)
   else
      UtilityAI_Reset()
      YawThrottle_Disable(I)
   end
end
