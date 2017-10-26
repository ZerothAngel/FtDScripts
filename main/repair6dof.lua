--! repair6dof
--@ commons control firstrun periodic
--@ shieldmanager balloonmanager sixdof altitudecontrol gunshipdefaults repair-ai6dof repair-aicommon
-- 6DoF repair AI
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
RepairAI = Periodic.new(AI_UpdateRate, RepairAI_Update)

SelectHeadingImpl(SixDoF)
SelectPositionImpl(SixDoF)
SelectAltitudeImpl(SixDoF)
SelectPitchImpl(SixDoF)
SelectRollImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      AltitudeControl:Tick(I)

      if ActivateWhen[I.AIMode] then
         RepairAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         RepairAI_Reset()
         V.Reset()
         SixDoF.Release(I)
      end

      Altitude_Apply(I)
      SixDoF.Update(I)
   else
      RepairAI_Reset()
      SixDoF.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
