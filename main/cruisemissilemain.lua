--! cruisemissile
--@ commons control firstrun periodic
--@ balloonmanager shieldmanager sixdof planelike planelikedefaults altitudecontrol cruisemissile
-- Cruise Missile main
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
CruiseAI = Periodic.new(AI_UpdateRate, CruiseAI_Update)

SelectHeadingImpl(SixDoF, PlaneLikeControl)
SelectPositionImpl(SixDoF, PlaneLikeControl)
SelectPitchImpl(SixDoF, PlaneLikeControl)
SelectRollImpl(SixDoF, PlaneLikeControl)

SelectHeadingImpl(PlaneLike)
SelectPositionImpl(PlaneLike)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(PlaneLike)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         -- Note that the planelike module is wholly dependent on
         -- the AI, so AltitudeControl and PlaneLike.Update
         -- have been moved here.
         AltitudeControl:Tick(I)

         CruiseAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         if BalloonManager_Kill() then V.Reset() end

         Altitude_Apply(I, DodgeAltitudeOffset, not CruiseIsClosing)
         PlaneLike.Update(I)

         CruiseAI_Detonator(I)
      else
         CruiseAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      CruiseAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
