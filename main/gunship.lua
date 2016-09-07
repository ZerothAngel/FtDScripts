--! gunship
--@ getselfinfo firstrun periodic
--@ dualprofile hover altitudecontrol fivedof gunship-ai
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
Hover = Periodic.create(Hover_UpdateRate, Altitude_Control, 1)
GunshipAI = Periodic.create(AI_UpdateRate, GunshipAI_Update)

Control_Reset = FiveDoF_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      if ActivateWhen[I.AIMode] then
         GunshipAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         FiveDoF_Reset()
      end

      Hover_Update(I)
      FiveDoF_Update(I)

      MissileMain:Tick(I)
   end
end
