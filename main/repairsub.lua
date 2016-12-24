--! repairsub
--@ commons firstrun periodic
--@ subcontrol depthcontrol yawthrottle repair-ai
-- Repair submarine main
SubControl = Periodic.create(SubControl_UpdateRate, Depth_Control, 1)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      SubControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         RepairAI_Reset()
      end

      SetAltitude(DesiredControlAltitude)
      SubControl_Update(I)
   else
      RepairAI_Reset()
      YawThrottle_Disable(I)
   end
end
