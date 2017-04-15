--! repairsub
--@ commons firstrun periodic
--@ shieldmanager subcontrol depthcontrol yawthrottle repair-ai
-- Repair submarine main
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
DepthControl = Periodic.create(DepthControl_UpdateRate, Depth_Control, 1)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      DepthControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end

      Depth_Apply(I)
      SubControl_Update(I)
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
   end

   ShieldManager:Tick(I)
end
