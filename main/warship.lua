--! warship
--@ commons control firstrun periodic
--@ shieldmanager dockmanager multiprofile rollturn sixdof ytdefaults naval-ai
-- Warship main
DockManager = Periodic.new(DockManager_UpdateRate, DockManager_Update, 3)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 1)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(SixDoF, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      V.SetAltitude(FixedAltitude)
      SixDoF.Update(I)

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   DockManager:Tick(I)
end
