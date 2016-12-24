--! thrustercraft
--@ commons firstrun periodic
--@ threedofjet altitudecontrol
ThreeDoFJet = Periodic.create(UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      ThreeDoFJet:Tick(I)

      SetAltitude(DesiredControlAltitude)
      ThreeDoFJet_Update(I)
   end
end
