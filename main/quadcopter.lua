--! quadcopter
--@ commons firstrun periodic
--@ threedofspinner altitudecontrol
ThreeDoFSpinner = Periodic.create(UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      ThreeDoFSpinner:Tick(I)

      Altitude_Apply(I)
      ThreeDoFSpinner_Update(I)
   else
      ThreeDoFSpinner_Disable(I)
   end
end
