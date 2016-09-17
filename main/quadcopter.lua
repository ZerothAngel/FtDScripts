--! quadcopter
--@ getselfinfo firstrun periodic
--@ threedofspinner altitudecontrol
ThreeDoFSpinner = Periodic.create(UpdateRate, Altitude_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFSpinner:Tick(I)

      ThreeDoFSpinner_Update(I)
   else
      ThreeDoFSpinner_Disable(I)
   end
end
