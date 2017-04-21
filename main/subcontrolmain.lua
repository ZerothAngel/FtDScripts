--! subcontrol
--@ commons control firstrun periodic
--@ subcontrol depthcontrol
DepthControl = Periodic.create(UpdateRate, Depth_Control)

SelectAltitudeImpl(SubControl)
SelectPitchImpl(SubControl)
SelectRollImpl(SubControl)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      DepthControl:Tick(I)

      Depth_Apply(I)
      SubControl.Update(I)
   end
end
