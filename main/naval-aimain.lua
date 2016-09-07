--! naval-ai
--@ getselfinfo firstrun periodic
--@ yawthrottle naval-ai
NavalAI = Periodic.create(UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() and ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      NavalAI:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   end
end
