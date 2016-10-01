--! repair-ai
--@ getselfinfo firstrun periodic
--@ yawthrottle repair-ai
RepairAI = Periodic.create(UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
   end
end
