--! utility
--@ getselfinfo firstrun periodic
--@ threedofspinner altitudecontrol yawthrottle utility-ai
-- Utility main
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
UtilityAI = Periodic.create(AI_UpdateRate, UtilityAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         CollectorDestinations = {}
      end

      ThreeDoFSpinner_Update(I)
   else
      CollectorDestinations = {}
      YawThrottle_Disable(I)
      ThreeDoFSpinner_Disable(I)
   end
end
