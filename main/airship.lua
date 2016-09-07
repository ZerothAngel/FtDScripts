--! airship
--@ getselfinfo firstrun periodic
--@ dualprofile threedofspinner altitudecontrol yawthrottle naval-ai
-- Airship main
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end

      ThreeDoFSpinner_Update(I)

      MissileMain:Tick(I)
   end
end
