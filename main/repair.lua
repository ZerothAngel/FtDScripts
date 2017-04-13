--! repair
--@ commons firstrun periodic
--@ aprthreedof altitudecontrol yawthrottle repair-ai
-- Quadcopter repair AI
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end

      Altitude_Apply(I)
      APRThreeDoF_Update(I)
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
      APRThreeDoF_Disable(I)
   end
end
