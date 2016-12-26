--! aerostat
--@ commons firstrun periodic
--@ threedofpump altitudecontrol
ThreeDoFPump = Periodic.create(UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      ThreeDoFPump:Tick(I)

      SetAltitude(DesiredControlAltitude+ControlAltitudeOffset)
      ThreeDoFPump_Update(I)
   end
end
