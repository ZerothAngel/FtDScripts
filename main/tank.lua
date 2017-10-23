--! tank
--@ commons control firstrun periodic
--@ shieldmanager multiprofile cannoncontrol tanksteer naval-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
Cannon = Periodic.create(Cannon_UpdateRate, CannonControl_Update, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(TankSteer)
SelectThrottleImpl(TankSteer)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      local AIMode = I.AIMode
      if ActivateWhen[AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         TankSteer.Release(I)
      end

      TankSteer.Update(I)

      if AIMode ~= "off" then
         Cannon:Tick(I)
      end
      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      TankSteer.Disable(I)
   end

   ShieldManager:Tick(I)
end