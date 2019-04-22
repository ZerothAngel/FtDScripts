--! planelike
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager multiprofile sixdof planelike planelikedefaults altitudecontrol naval-ai
-- Plane-like main
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(SixDoF, PlaneLikeControl)
SelectPitchImpl(SixDoF, PlaneLikeControl)
SelectRollImpl(SixDoF, PlaneLikeControl)

SelectHeadingImpl(PlaneLike)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(PlaneLike)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         -- Note that the airplane module is wholly dependent on
         -- the AI, so AltitudeControl and PlaneLike.Update
         -- have been moved here.
         AltitudeControl:Tick(I)

         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         if BalloonManager_Kill() then V.Reset() end

         Altitude_Apply(I, DodgeAltitudeOffset)
         PlaneLike.Update(I)
      else
         NavalAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
