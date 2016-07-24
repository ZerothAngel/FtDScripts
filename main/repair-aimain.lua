--! repair-ai
--@ getselfinfo firstrun periodic
--@ repair-ai
RepairAI = Periodic.create(UpdateRate, RepairAI_Update)

function Update(I)
   if not I:IsDocked() and ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      RepairAI:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   else
      ParentID = nil
      RepairTargetID = nil
   end
end
