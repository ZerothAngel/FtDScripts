--! gunshipadof
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager multiprofile alldof altitudecontrol gunship-ai
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control, 1)
GunshipAI = Periodic.create(AI_UpdateRate, GunshipAI_Update)

SelectHeadingImpl(AllDoF)
SelectPositionImpl(AllDoF)
SelectAltitudeImpl(AllDoF)
SelectPitchImpl(AllDoF)
SelectRollImpl(AllDoF)

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
         GunshipAI_Reset()
         V.Reset()
      end

      Altitude_Apply(I, DodgeAltitudeOffset)
      AllDoF.Update(I)

      MissileMain:Tick(I)
   else
      AllDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
