--! repairsub
--@ commons control firstrun periodic
--@ shieldmanager subcontrol rollturn sixdof depthcontrol ytdefaults repair-ai repair-aicommon
-- Repair submarine main
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
DepthControl = Periodic.new(DepthControl_UpdateRate, Depth_Control, 1)
RepairAI = Periodic.new(AI_UpdateRate, RepairAI_Update)

SelectHeadingImpl(SixDoF, RollTurnControl)
SelectRollImpl(SubControl, RollTurnControl)

SelectHeadingImpl(RollTurn)
SelectThrottleImpl(SixDoF)
SelectAltitudeImpl(SubControl)
SelectPitchImpl(SubControl)
SelectRollImpl(RollTurn)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   FirstRun(I)
   if not C:IsDocked() then
      DepthControl:Tick(I)

      if ActivateWhen[C:MovementMode()] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         RepairAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      Depth_Apply(I)
      SubControl.Update(I)
      SixDoF.Update(I)
   else
      RepairAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
end
