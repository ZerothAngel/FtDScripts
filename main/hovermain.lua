--! hover
--@ getselfinfo firstrun periodic
--@ stabilizer hover
Hover = Periodic.create(UpdateRate, Hover_Control)

function Update(I)
   if not I:IsDocked() and I.AIMode ~= "off" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      Hover_Update(I)
      Stabilizer_Update(I)
   end
end
