--! repairheli
--@ getselfinfo firstrun periodic
--@ stabilizer hover altitudecontrol yawthrottle repair-ai
-- Repair submarine main
Hover = Periodic.create(Hover_UpdateRate, Altitude_Control)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end

      Hover_Update(I)
      Stabilizer_Update(I)
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
      Hover_Disable(I)
   end
end
