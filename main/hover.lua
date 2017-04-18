--! hover
--@ commons firstrun periodic
--@ balloonmanager sixdof hoverdefaults altitudecontrol
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 1)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      Altitude_Apply(I)
      SixDoF_Update(I)
   else
      SixDoF_Disable(I)
   end

   BalloonManager:Tick(I)
end
