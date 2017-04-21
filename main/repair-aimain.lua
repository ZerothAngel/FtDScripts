--! repair-ai
--@ commons control firstrun periodic
--@ sixdof ytdefaults repair-ai repair-aicommon
RepairAI = Periodic.create(UpdateRate, RepairAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         RepairAI_Reset()
         V.Reset()
      end

      SixDoF.Update(I)
   else
      RepairAI_Reset()
      SixDoF.Disable(I)
   end
end
