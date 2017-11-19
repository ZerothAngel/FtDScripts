--! subpump
--@ commons control firstrun periodic
--@ threedofpump depthcontrol
DepthControl = Periodic.new(UpdateRate, Depth_Control)

SelectAltitudeImpl(ThreeDoFPump)
SelectPitchImpl(ThreeDoFPump)
SelectRollImpl(ThreeDoFPump)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      DepthControl:Tick(I)

      Depth_Apply(I)
      ThreeDoFPump.Update(I)
   end
end
