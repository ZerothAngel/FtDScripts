--! tabularasa
--@ yawthrottle commons firstrun periodic
function TabulaRasa_Update(I)
   YawThrottle_Reset()
end

TabulaRasa = Periodic.create(UpdateRate, TabulaRasa_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         TabulaRasa:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end
   else
      YawThrottle_Disable(I)
   end
end
