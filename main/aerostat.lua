--! aerostat
--@ getselfinfo firstrun periodic
--@ threedofpump altitudecontrol
ThreeDoFPump = Periodic.create(UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFPump:Tick(I)

      ThreeDoFPump_Update(I)
   end
end
