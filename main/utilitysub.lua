--! utilitysub
--@ commons control firstrun periodic
--@ dockmanager shieldmanager rollturn subcontrol sixdof depthcontrol ytdefaults utility-ai utility-aicommon
-- Utility submarine main
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 3)
DockManager = Periodic.new(DockManager_UpdateRate, DockManager_Update, 2)
DepthControl = Periodic.new(DepthControl_UpdateRate, Depth_Control, 1)
UtilityAI = Periodic.new(AI_UpdateRate, UtilityAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(SubControl, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SubControl)
SelectPitchImpl(SubControl)
SelectRollImpl(RollTurn)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      DepthControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         UtilityAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         UtilityAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      Depth_Apply(I)
      SubControl.Update(I)
      SixDoF.Update(I)
   else
      UtilityAI_Reset()
      SixDoF.Disable(I)
   end

   DockManager:Tick(I)
   ShieldManager:Tick(I)
end
