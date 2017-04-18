--! submarine
--@ commons firstrun periodic
--@ shieldmanager dualprofile subcontrol sixdof depthcontrol naval-ai
-- Submarine main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
SubControl = Periodic.create(SubControl_UpdateRate, Depth_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      SubControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         SixDoF_Update(I)
      else
         NavalAI_Reset()
      end

      Depth_Apply(I, DodgeAltitudeOffset)
      SubControl_Update(I)

      MissileMain:Tick(I)
   else
      NavalAI_Reset()
      SixDoF_Disable(I)
   end

   ShieldManager:Tick(I)
end
