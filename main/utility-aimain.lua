--! utility-ai
--@ commons control firstrun periodic
--@ rollturn pitchthrottle sixdof ytdefaults utility-ai utility-aicommon
UtilityAI = Periodic.new(UpdateRate, UtilityAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectThrottleImpl(SixDoF, PitchThrottleControl)
SelectRollImpl(SixDoF, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(PitchThrottle)
SelectAltitudeImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      if ActivateWhen[C:MovementMode()] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         UtilityAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      V.SetAltitude(FixedAltitude)
      PitchThrottle.Update(I)
      SixDoF.Update(I)
   else
      UtilityAI_Reset()
      SixDoF.Disable(I)
   end
end
