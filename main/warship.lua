--! warship
--@ getselfinfo firstrun periodic
--@ dualprofile yawthrottle naval-ai
-- Warship main
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
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
   else
      YawThrottle_Disable(I)
   end
end
