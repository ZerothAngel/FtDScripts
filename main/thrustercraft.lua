--! thrustercraft
--@ getselfinfo firstrun periodic
--@ threedofjet altitudecontrol
ThreeDoFJet = Periodic.create(UpdateRate, Altitude_Control)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      ThreeDoFJet:Tick(I)

      SetAltitude(DesiredControlAltitude)
      ThreeDoFJet_Update(I)
   end
end
