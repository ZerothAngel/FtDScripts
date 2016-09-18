--! thrustercraft
--@ getselfinfo firstrun periodic
--@ threedofjet altitudecontrol
ThreeDoFJet = Periodic.create(UpdateRate, Altitude_Control)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFJet:Tick(I)

      ThreeDoFJet_Update(I)
   end
end
