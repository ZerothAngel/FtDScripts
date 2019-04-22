--! gunshipadof
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager multiprofile alldof altitudecontrol gunship-ai
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
MissileMain = Periodic.new(Missile_UpdateRate, MissileMain_Update, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
GunshipAI = Periodic.new(AI_UpdateRate, GunshipAI_Update)

SelectHeadingImpl(AllDoF)
SelectPositionImpl(AllDoF)
SelectAltitudeImpl(AllDoF)
SelectPitchImpl(AllDoF)
SelectRollImpl(AllDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[C:MovementMode()] then
         GunshipAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         GunshipAI_Reset()
         V.Reset()
      end

      if BalloonManager_Kill() then V.Reset() end

      Altitude_Apply(I, DodgeAltitudeOffset)
      AllDoF.Update(I)

      MissileMain:Tick(I)
   else
      AllDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
