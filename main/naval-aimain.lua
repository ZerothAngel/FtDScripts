--! naval-ai
--@ commons control firstrun periodic
--@ rollturn sixdof ytdefaults naval-ai
NavalAI = Periodic.new(UpdateRate, NavalAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(SixDoF, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         NavalAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         NavalAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      SixDoF.Update(I)
   else
      NavalAI_Reset()
      SixDoF.Disable(I)
   end
end
