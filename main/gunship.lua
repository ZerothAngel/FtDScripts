--! gunship
--@ commons firstrun periodic
--@ shieldmanager dualprofile hover altitudecontrol fivedof gunship-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
Hover = Periodic.create(Hover_UpdateRate, Altitude_Control, 1)
GunshipAI = Periodic.create(AI_UpdateRate, GunshipAI_Update)

Control_Reset = FiveDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Hover:Tick(I)

      if ActivateWhen[I.AIMode] then
         GunshipAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         FiveDoF_Reset()
         DodgeAltitudeOffset = nil
      end

      if DodgeAltitudeOffset then
         AdjustAltitude(DodgeAltitudeOffset)
      else
         SetAltitude(DesiredControlAltitude+ControlAltitudeOffset)
      end
      Hover_Update(I)
      FiveDoF_Update(I)

      MissileMain:Tick(I)
   else
      Hover_Disable(I)
   end

   ShieldManager:Tick(I)
end
