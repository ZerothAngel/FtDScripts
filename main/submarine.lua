--! submarine
--@ getselfinfo firstrun periodic
--@ dualprofile subcontrol depthcontrol yawthrottle naval-ai
-- Submarine main
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
SubControl = Periodic.create(SubControl_UpdateRate, Depth_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

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
   else
      YawThrottle_Disable(I)
   end
end
