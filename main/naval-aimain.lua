--! naval-ai
--@ getselfinfo firstrun periodic
--@ naval-ai
NavalAI = Periodic.create(UpdateRate, NavalAI_Update)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and ((ActivateWhenOn and AIMode == "on") or
                            AIMode == "combat") then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      NavalAI:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   end
end
