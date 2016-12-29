--! repairquad
--@ commons firstrun periodic
--@ threedofspinner altitudecontrol yawthrottle repair-ai
-- Quadcopter repair AI
ThreeDoFSpinner = Periodic.create(Quadcopter_UpdateRate, Altitude_Control)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      ThreeDoFSpinner:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end

      SetAltitude(DesiredControlAltitude+ControlAltitudeOffset)
      ThreeDoFSpinner_Update(I)
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
      ThreeDoFSpinner_Disable(I)
   end
end
