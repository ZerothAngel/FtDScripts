--! scout
--@ commons firstrun periodic
--@ cameratrack shieldmanager threedofspinner altitudecontrol yawthrottle naval-ai
-- Scout main
CameraTrack = Periodic.create(CameraTrack_UpdateRate, CameraTrack_Update, 3)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end

      SetAltitude(DesiredControlAltitude)
      ThreeDoFSpinner_Update(I)

      CameraTrack:Tick(I)
   else
      YawThrottle_Disable(I)
      ThreeDoFSpinner_Disable(I)
   end

   ShieldManager:Tick(I)
end
