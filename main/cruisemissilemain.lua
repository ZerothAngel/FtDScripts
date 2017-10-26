--! cruisemissile
--@ commons control firstrun periodic
--@ balloonmanager shieldmanager airplane altitudecontrol cruisemissile
-- Cruise Missile main
BalloonManager = Periodic.new(BalloonManager_UpdateRate, BalloonManager_Control, 3)
ShieldManager = Periodic.new(ShieldManager_UpdateRate, ShieldManager_Control, 2)
AltitudeControl = Periodic.new(AltitudeControl_UpdateRate, Altitude_Control, 1)
CruiseAI = Periodic.new(AI_UpdateRate, CruiseAI_Update)

SelectHeadingImpl(Airplane)
SelectPositionImpl(Airplane)
SelectThrottleImpl(Airplane)
SelectAltitudeImpl(Airplane)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         -- Note that the airplane module is wholly dependent on
         -- the AI, so AltitudeControl and Airplane.Update
         -- have been moved here.
         AltitudeControl:Tick(I)

         CruiseAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         Altitude_Apply(I, DodgeAltitudeOffset, not CruiseIsClosing)
         Airplane.Update(I)
      else
         CruiseAI_Reset()
         Airplane.Release(I)
      end
   else
      CruiseAI_Reset()
      Airplane.Disable(I)
   end

   ShieldManager:Tick(I)
   BalloonManager:Tick(I)
end
