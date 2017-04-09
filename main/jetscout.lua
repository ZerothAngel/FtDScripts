--! jetscout
--@ commons firstrun periodic
--@ cameratrack shieldmanager balloonmanager altitudecontrol sixdof gunship-ai
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 4)
CameraTrack = Periodic.create(CameraTrack_UpdateRate, CameraTrack_Update, 3)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
Hover = Periodic.create(Hover_UpdateRate, Altitude_Control, 1)
GunshipAI = Periodic.create(AI_UpdateRate, GunshipAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I, true)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Hover:Tick(I)

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

      CameraTrack:Tick(I)
   else
      SixDoF_Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
