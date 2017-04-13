--! hover
--@ commons firstrun periodic
--@ balloonmanager aprthreedof altitudecontrol
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 1)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      Altitude_Apply(I)
      APRThreeDoF_Update(I)
   else
      APRThreeDoF_Disable(I)
   end

   BalloonManager:Tick(I)
end
