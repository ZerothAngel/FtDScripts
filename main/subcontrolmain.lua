--! subcontrol
--@ getselfinfo firstrun periodic
--@ subcontrol
SubControl = Periodic.create(UpdateRate, SubControl_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      SubControl_Update(I)
   end
end
