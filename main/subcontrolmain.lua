--! subcontrol
--@ getselfinfo firstrun periodic
--@ subcontrol depthcontrol
SubControl = Periodic.create(UpdateRate, Depth_Control)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      SetAltitude(DesiredControlAltitude)
      SubControl_Update(I)
   end
end
