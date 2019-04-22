--! tank
--@ commons control firstrun periodic
--@ shieldmanager multiprofile cannoncontrol targetaccel tanksteer naval-ai
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 2)
Cannon = Periodic.new(Cannon_UpdateRate, CannonControl_Update, 1)
NavalAI = Periodic.new(AI_UpdateRate, NavalAI_Update)

SelectHeadingImpl(TankSteer)
SelectThrottleImpl(TankSteer)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if AccelerationSamples then CalculateTargetAcceleration(AccelerationSamples) end
      if ActivateWhen[C:MovementMode()] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         TankSteer.Release(I)
      end

      TankSteer.Update(I)

      if C:FiringMode() ~= "Off" then
         Cannon:Tick(I)
      end
      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      TankSteer.Disable(I)
   end

   ShieldManager:Tick(I)
end
