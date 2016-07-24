--! repairsub
--@ getselfinfo firstrun periodic
--@ subcontrol repair-ai
-- Repair submarine main
SubControl = Periodic.create(SubControl_UpdateRate, SubControl_Control, 1)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         ParentID = nil
         RepairTargetID = nil
      end

      SubControl_Update(I)
   end
end
