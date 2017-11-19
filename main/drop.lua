--! drop
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager sixdof altitudecontrol gunshipdefaults drop-ai
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
DropAI = Periodic.new(AI_UpdateRate, DropAI_Update)

SelectHeadingImpl(SixDoF)
SelectPositionImpl(SixDoF)
SelectAltitudeImpl(SixDoF)
SelectPitchImpl(SixDoF)
SelectRollImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I, true)
   FirstRun(I)
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         DropAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         DropAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      if BalloonManager_Kill() then V.Reset() end

      Altitude_Apply(I, DodgeAltitudeOffset, not DropAI_Closing)
      SixDoF.Update(I)
   else
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
