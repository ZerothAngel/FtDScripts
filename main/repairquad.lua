--! repairquad
--@ getselfinfo firstrun periodic
--@ threedofspinner altitudecontrol yawthrottle repair-ai
-- Quadcopter repair AI
ThreeDoFSpinner = Periodic.create(Quadcopter_UpdateRate, Altitude_Control)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFSpinner:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end

      SetAltitude(DesiredControlAltitude)
      ThreeDoFSpinner_Update(I)
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
      ThreeDoFSpinner_Disable(I)
   end
end
