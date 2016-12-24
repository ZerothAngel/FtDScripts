--! subpump
--@ commons firstrun periodic
--@ threedofpump depthcontrol
ThreeDoFPump = Periodic.create(UpdateRate, Depth_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      ThreeDoFPump:Tick(I)

      SetAltitude(DesiredControlAltitude)
      ThreeDoFPump_Update(I)
   end
end
