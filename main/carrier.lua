--! carrier
--@ commons control firstrun periodic
--@ shieldmanager dockmanager sixdof ytdefaults naval-ai
-- Warship main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
DockManager = Periodic.create(DockManager_UpdateRate, DockManager_Update, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end

   DockManager:Tick(I)
   ShieldManager:Tick(I)
end
