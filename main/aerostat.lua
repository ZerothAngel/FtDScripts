--! aerostat
--@ commons control firstrun periodic
--@ threedofpump altitudecontrol
AltitudeControl = Periodic.create(UpdateRate, Altitude_Control)

SelectAltitudeImpl(ThreeDoFPump)
SelectPitchImpl(ThreeDoFPump)
SelectRollImpl(ThreeDoFPump)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      Altitude_Apply(I)
      ThreeDoFPump.Update(I)
   end
end
