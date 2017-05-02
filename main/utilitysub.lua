--! utilitysub
--@ commons control firstrun periodic
--@ dockmanager shieldmanager subcontrol sixdof depthcontrol ytdefaults utility-ai utility-aicommon
-- Utility submarine main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 3)
DockManager = Periodic.create(DockManager_UpdateRate, DockManager_Update, 2)
DepthControl = Periodic.create(DepthControl_UpdateRate, Depth_Control, 1)
UtilityAI = Periodic.create(AI_UpdateRate, UtilityAI_Update)

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SubControl)
SelectPitchImpl(SubControl)
SelectRollImpl(SubControl)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
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
