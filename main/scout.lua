--! scout
--@ commons control firstrun periodic
--@ cameratrack shieldmanager balloonmanager sixdof altitudecontrol airshipdefaults naval-ai
-- Scout main
CameraTrack = Periodic.create(CameraTrack_UpdateRate, CameraTrack_Update, 4)
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SixDoF)
SelectPitchImpl(SixDoF)
SelectRollImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      Altitude_Apply(I, DodgeAltitudeOffset)
      SixDoF.Update(I)

      CameraTrack:Tick(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
