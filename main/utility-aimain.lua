--! utility-ai
--@ getselfinfo firstrun periodic
--@ yawthrottle utility-ai
UtilityAI = Periodic.create(UpdateRate, UtilityAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         CollectorDestinations = {}
      end
   end
end
