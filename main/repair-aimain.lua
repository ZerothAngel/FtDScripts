--! repair-ai
--@ commons control firstrun periodic
--@ rollturn sixdof ytdefaults repair-ai repair-aicommon
RepairAI = Periodic.new(UpdateRate, RepairAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(SixDoF, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         RepairAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      V.SetAltitude(FixedAltitude)
      SixDoF.Update(I)
   else
      RepairAI_Reset()
      SixDoF.Disable(I)
   end
end
