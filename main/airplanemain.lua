--! airplane
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager multiprofile airplane altitudecontrol naval-ai
-- Airship main
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(Airplane)
SelectThrottleImpl(Airplane)
SelectAltitudeImpl(Airplane)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         -- Note that the airplane module is wholly dependent on
         -- the AI, so AltitudeControl and Airplane.Update
         -- have been moved here.
         AltitudeControl:Tick(I)

         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         if BalloonManager_Kill() then V.Reset() end

         Altitude_Apply(I, DodgeAltitudeOffset)
         Airplane.Update(I)
      else
         NavalAI_Reset()
         Airplane.Release(I)
      end

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      Airplane.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
