--! airship
--@ commons firstrun periodic
--@ shieldmanager dualprofile threedofspinner altitudecontrol yawthrottle naval-ai
-- Airship main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         NavalAI_Reset()
      end

      Altitude_Apply(I, DodgeAltitudeOffset)
      ThreeDoFSpinner_Update(I)

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      YawThrottle_Disable(I)
      ThreeDoFSpinner_Disable(I)
   end

   ShieldManager:Tick(I)
end
