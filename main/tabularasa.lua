--! tabularasa
--@ commons firstrun periodic sixdof
function TabulaRasa_Update(I)
   SixDoF_Reset()
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

         SixDoF_Update(I)
      end
   else
      SixDoF_Disable(I)
   end
end
