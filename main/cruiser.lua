--! cruiser
--@ commons control firstrun periodic
--@ shieldmanager dockmanager multiprofile cannoncontrol targetaccel rollturn subcontrol sixdof ytdefaults naval-ai
-- Cruiser main
DockManager = Periodic.new(DockManager_UpdateRate, DockManager_Update, 3)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 1)
Cannon = Periodic.new(Cannon_UpdateRate, CannonControl_Update)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

-- Set up a hybrid control system for altitude-pitch-roll
Hybrid = {}
function Hybrid.SetAltitude(Alt)
   SubControl.SetAltitude(Alt)
   SixDoF.SetAltitude(Alt)
end
function Hybrid.SetPitch(Angle)
   SubControl.SetPitch(Angle)
   SixDoF.SetPitch(Angle)
end
function Hybrid.SetRoll(Angle)
   SubControl.SetRoll(Angle)
   SixDoF.SetRoll(Angle)
end

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(Hybrid, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(Hybrid)
SelectPitchImpl(Hybrid)
SelectRollImpl(RollTurn)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if AccelerationSamples then CalculateTargetAcceleration(AccelerationSamples) end
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
      SubControl.Update(I)
      SixDoF.Update(I)

      Cannon:Tick(I)
      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end

   DockManager:Tick(I)
   ShieldManager:Tick(I)
end
