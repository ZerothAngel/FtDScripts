--! utility
--@ commons firstrun periodic
--@ threedofspinner altitudecontrol yawthrottle utility-ai
-- Utility main
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
UtilityAI = Periodic.create(AI_UpdateRate, UtilityAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         UtilityAI_Reset()
      end

      Altitude_Apply(I)
      ThreeDoFSpinner_Update(I)
   else
      UtilityAI_Reset()
      YawThrottle_Disable(I)
      ThreeDoFSpinner_Disable(I)
   end
end
