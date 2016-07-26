--! hover
--@ getselfinfo firstrun periodic
--@ stabilizer hover
Hover = Periodic.create(UpdateRate, Hover_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      Hover_Update(I)
      Stabilizer_Update(I)
   end
end
