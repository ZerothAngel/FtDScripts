--! utility
--@ commons control firstrun periodic
--@ dockmanager shieldmanager balloonmanager rollturn sixdof altitudecontrol airshipdefaults utility-ai utility-aicommon
-- Utility main
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 4)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
DockManager = Periodic.new(DockManager_UpdateRate, DockManager_Update, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
UtilityAI = Periodic.new(AI_UpdateRate, UtilityAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(SixDoF, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SixDoF)
SelectPitchImpl(SixDoF)
SelectRollImpl(RollTurn)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         UtilityAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      if BalloonManager_Kill() then V.Reset() end

      Altitude_Apply(I)
      SixDoF.Update(I)
   else
      UtilityAI_Reset()
      SixDoF.Disable(I)
   end

   DockManager:Tick(I)
   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
