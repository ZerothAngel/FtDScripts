--! tabularasa
--@ yawthrottle getselfinfo firstrun periodic
function TabulaRasa_Update(I)
   YawThrottle_Reset()
end

TabulaRasa = Periodic.create(UpdateRate, TabulaRasa_Update)

function Update(I)
   if ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      TabulaRasa:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   end
end
