--! 3dofpump
--@ getselfinfo firstrun periodic
--@ threedofpump altitudecontrol
ThreeDoFPump = Periodic.create(UpdateRate, Altitude_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFPump:Tick(I)

      ThreeDoFPump_Update(I)
   end
end
