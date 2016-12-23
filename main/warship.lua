--! warship
--@ commons firstrun periodic
--@ shieldmanager dualprofile yawthrottle naval-ai
-- Warship main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      C = Commons.create(I)

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

   ShieldManager:Tick(I)
end
