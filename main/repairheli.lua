--! repairheli
--@ getselfinfo firstrun periodic
--@ stabilizer hover repair-ai
-- Repair submarine main
Hover = Periodic.create(Hover_UpdateRate, Hover_Control)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and AIMode ~= "off" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then

         RepairAI:Tick(I)

         -- Suppress default AI
         if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

         YawThrottle_Update(I)
      else
         ParentID = nil
         RepairTargetID = nil
      end

      Hover_Update(I)
      Stabilizer_Update(I)
   end
end
