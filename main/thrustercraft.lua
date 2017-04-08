--! thrustercraft
--@ commons firstrun periodic
--@ balloonmanager threedofjet altitudecontrol
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 1)
ThreeDoFJet = Periodic.create(Hover_UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      ThreeDoFJet:Tick(I)

      SetAltitude(DesiredControlAltitude+ControlAltitudeOffset, MinAltitude)
      ThreeDoFJet_Update(I)
   else
      ThreeDoFJet_Disable(I)
   end

   BalloonManager:Tick(I)
end
