--! airship
--@ getselfinfo firstrun periodic
--@ dualprofile stabilizer hover naval-ai
-- Airship main
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
Hover = Periodic.create(Hover_UpdateRate, Hover_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end

      Hover_Update(I)
      Stabilizer_Update(I)

      MissileMain:Tick(I)
   end
end
