--! subpump
--@ getselfinfo firstrun periodic
--@ threedofpump depthcontrol
ThreeDoFPump = Periodic.create(UpdateRate, Depth_Control)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFPump:Tick(I)

      SetAltitude(DesiredControlAltitude)
      ThreeDoFPump_Update(I)
   end
end
