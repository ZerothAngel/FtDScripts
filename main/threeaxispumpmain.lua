--! threeaxispump
--@ getselfinfo firstrun periodic
--@ threeaxispump
ThreeAxisPump = Periodic.create(UpdateRate, ThreeAxisPump_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeAxisPump:Tick(I)

      ThreeAxisPump_Update(I)
   end
end
