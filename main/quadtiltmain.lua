--! quadtilt
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager multiprofile alldof altitudecontrol quadtilt naval-ai
-- Airship main
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(AllDoF, QuadTiltControl)
SelectThrottleImpl(AllDoF, QuadTiltControl)

SelectHeadingImpl(QuadTilt)
SelectThrottleImpl(QuadTilt)
SelectAltitudeImpl(AllDoF)
SelectPitchImpl(AllDoF)
SelectRollImpl(AllDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
      end

      if BalloonManager_Kill() then V.Reset() end

      Altitude_Apply(I, DodgeAltitudeOffset)
      AllDoF.Update(I)
      QuadTilt.Update(I)

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      AllDoF.Disable(I)
      QuadTilt.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
