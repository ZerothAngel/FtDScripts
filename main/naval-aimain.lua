--! naval-ai
--@ commons firstrun periodic
--@ yawthrottle naval-ai
NavalAI = Periodic.create(UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end
   else
      YawThrottle_Disable(I)
   end
end
