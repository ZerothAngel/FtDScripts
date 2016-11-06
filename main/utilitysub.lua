--! utilitysub
--@ getselfinfo firstrun periodic
--@ subcontrol depthcontrol yawthrottle utility-ai
-- Utility submarine main
SubControl = Periodic.create(SubControl_UpdateRate, Depth_Control, 1)
UtilityAI = Periodic.create(AI_UpdateRate, UtilityAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         UtilityAI_Reset()
      end

      SubControl_Update(I)
   else
      UtilityAI_Reset()
      YawThrottle_Disable(I)
   end
end
