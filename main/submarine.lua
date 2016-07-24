--! submarine
--@ getselfinfo firstrun periodic
--@ dualprofile subcontrol naval-ai
-- Submarine main
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
SubControl = Periodic.create(SubControl_UpdateRate, SubControl_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end

      SubControl_Update(I)

      MissileMain:Tick(I)
   end
end
