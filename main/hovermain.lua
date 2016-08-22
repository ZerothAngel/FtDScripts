--! hover
--@ getselfinfo firstrun periodic
--@ stabilizer hover altitudecontrol
Hover = Periodic.create(UpdateRate, Altitude_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      Hover_Update(I)
      Stabilizer_Update(I)
   end
end
