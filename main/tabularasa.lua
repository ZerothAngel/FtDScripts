--! tabularasa
--@ commons control firstrun periodic sixdof ytdefaults
function TabulaRasa_Update(I)
   V.Reset()
end

TabulaRasa = Periodic.new(UpdateRate, TabulaRasa_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         TabulaRasa:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      SixDoF.Disable(I)
   end
end
