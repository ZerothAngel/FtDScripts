--! quadcopter
--@ getselfinfo firstrun periodic
--@ threedofspinner
ThreeDoFSpinner = Periodic.create(UpdateRate, ThreeDoFSpinner_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFSpinner:Tick(I)

      ThreeDoFSpinner_Update(I)
   end
end
