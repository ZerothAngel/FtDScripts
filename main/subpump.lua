--! subpump
--@ commons control firstrun periodic
--@ threedofpump depthcontrol
DepthControl = Periodic.create(UpdateRate, Depth_Control)

SelectAltitudeImpl(ThreeDoFPump)
SelectPitchImpl(ThreeDoFPump)
SelectRollImpl(ThreeDoFPump)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      DepthControl:Tick(I)

      Depth_Apply(I)
      ThreeDoFPump.Update(I)
   end
end
