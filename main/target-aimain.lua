--! target-ai
--@ getselfinfo firstrun periodic
--@ yawthrottle target-ai
TargetAI = Periodic.create(UpdateRate, TargetAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if ActivateWhen[I.AIMode] then
         TargetAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         TargetAI_Reset()
      end
   else
      TargetAI_Reset()
      YawThrottle_Disable(I)
   end
end
