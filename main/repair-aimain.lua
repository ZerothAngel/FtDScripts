--! repair-ai
--@ commons firstrun periodic
--@ yawthrottle repair-ai
RepairAI = Periodic.create(UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
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
