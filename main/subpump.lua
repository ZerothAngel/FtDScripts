--! subpump
--@ commons firstrun periodic
--@ threedofpump depthcontrol
ThreeDoFPump = Periodic.create(UpdateRate, Depth_Control)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      C = Commons.create(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFPump:Tick(I)

      SetAltitude(DesiredControlAltitude)
      ThreeDoFPump_Update(I)
   end
end
