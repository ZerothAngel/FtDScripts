--! repair-ai
--@ getselfinfo firstrun periodic
--@ repair-ai
RepairAI = Periodic.create(UpdateRate, RepairAI_Update)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and ((ActiateWhenOn and I.AIMode == "on") or
                            AIMode == "combat") then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      RepairAI:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   else
      ParentID = nil
      RepairTargetID = nil
   end
end
