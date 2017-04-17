--! airplane
--@ commons firstrun periodic
--@ shieldmanager balloonmanager dualprofile airplane altitudecontrol naval-ai
-- Airship main
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = Airplane_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         -- Note that the airplane module is wholly dependent on
         -- the AI, so AltitudeControl and Airplane_Update
         -- have been moved here.
         AltitudeControl:Tick(I)

         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         Altitude_Apply(I, DodgeAltitudeOffset)
         Airplane_Update(I)
      else
         NavalAI_Reset()
         Airplane_Release(I)
      end

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      Airplane_Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
