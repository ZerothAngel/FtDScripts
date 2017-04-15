--! drop
--@ commons firstrun periodic
--@ shieldmanager balloonmanager sixdof altitudecontrol drop-ai
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control, 1)
DropAI = Periodic.create(AI_UpdateRate, DropAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I, true)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         DropAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         SixDoF_Reset()
         DodgeAltitudeOffset = nil
      end

      Altitude_Apply(I, DodgeAltitudeOffset, not DropAI_Closing)
      SixDoF_Update(I)
   else
      SixDoF_Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
