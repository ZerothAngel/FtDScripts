--! subcontrol
--@ getselfinfo firstrun periodic
--@ subcontrol depthcontrol
SubControl = Periodic.create(UpdateRate, Depth_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      SubControl_Update(I)
   end
end
