--! hover
--@ commons firstrun periodic
--@ stabilizer hover altitudecontrol
Hover = Periodic.create(UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Hover:Tick(I)

      SetAltitude(DesiredControlAltitude)
      Hover_Update(I)
      Stabilizer_Update(I)
   else
      Hover_Disable(I)
   end
end
