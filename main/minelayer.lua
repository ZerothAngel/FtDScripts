--! minelayer
--@ commons firstrun periodic
--@ shieldmanager mobilemine sixdof altitudecontrol gunship-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control, 1)
GunshipAI = Periodic.create(AI_UpdateRate, GunshipAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         GunshipAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         SixDoF_Reset()
         DodgeAltitudeOffset = nil
      end

      Altitude_Apply(I, DodgeAltitudeOffset)
      SixDoF_Update(I)

      MissileMain:Tick(I)
   else
      SixDoF_Disable(I)
   end

   ShieldManager:Tick(I)
end
