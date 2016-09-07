--! gatherer-ai
--@ getselfinfo firstrun periodic
--@ yawthrottle gatherer-ai
GathererAI = Periodic.create(UpdateRate, GathererAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() and ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      GathererAI:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   end
end
