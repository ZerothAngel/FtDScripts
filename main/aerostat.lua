--! aerostat
--@ commons control firstrun periodic
--@ threedofpump altitudecontrol
AltitudeControl = Periodic.new(UpdateRate, Altitude_Control)

SelectAltitudeImpl(ThreeDoFPump)
SelectPitchImpl(ThreeDoFPump)
SelectRollImpl(ThreeDoFPump)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      Altitude_Apply(I)
      ThreeDoFPump.Update(I)
   end
end
