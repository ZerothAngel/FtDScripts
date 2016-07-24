--! warship
--@ getselfinfo firstrun periodic
--@ dualprofile naval-ai
-- Warship main
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end

      MissileMain:Tick(I)
   end
end
