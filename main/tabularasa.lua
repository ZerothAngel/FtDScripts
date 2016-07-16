--! tabularasa
--@ yawthrottle getselfinfo firstrun periodic
function TabulaRasa_Update(I)
   YawThrottle_Reset()
end

TabulaRasa = Periodic.create(UpdateRate, TabulaRasa_Update)

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      TabulaRasa:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   end
end
