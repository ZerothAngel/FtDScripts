--! repair
--@ commons firstrun periodic
--@ shieldmanager balloonmanager sixdof altitudecontrol repair-ai
-- Quadcopter repair AI
BalloonManager = Periodic.create(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.create(AltitudeControl_UpdateRate, Altitude_Control, 1)
RepairAI = Periodic.create(AI_UpdateRate, RepairAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         SixDoF_Update(I)
      else
         RepairAI_Reset()
      end

      Altitude_Apply(I)
      SixDoF_Update(I)
   else
      RepairAI_Reset()
      SixDoF_Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
