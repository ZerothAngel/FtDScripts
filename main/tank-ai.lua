--! tank-ai
--@ commons control firstrun periodic
--@ tanksteer naval-ai
NavalAI = Periodic.new(UpdateRate, NavalAI_Update)

SelectHeadingImpl(TankSteer)
SelectThrottleImpl(TankSteer)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         TankSteer.Release(I)
      end

      TankSteer.Update(I)
   else
      NavalAI_Reset()
      TankSteer.Disable(I)
   end
end
