--! repairsub
--@ getselfinfo firstrun periodic
--@ subcontrol repair-ai
-- Repair submarine main
SubControl = Periodic.create(SubControl_UpdateRate, SubControl_Control, 1)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and AIMode ~= "off" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then

         RepairAI:Tick(I)

         -- Suppress default AI
         if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

         YawThrottle_Update(I)
      else
         ParentID = nil
         RepairTargetID = nil
      end

      SubControl_Update(I)
   end
end
