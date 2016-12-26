--! drop
--@ commons firstrun periodic
--@ shieldmanager altitudecontrol sixdof drop-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
Hover = Periodic.create(Hover_UpdateRate, Altitude_Control, 1)
DropAI = Periodic.create(AI_UpdateRate, DropAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Hover:Tick(I)

      if ActivateWhen[I.AIMode] then
         DropAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         SixDoF_Reset()
         DodgeAltitudeOffset = nil
      end

      if DodgeAltitudeOffset then
         AdjustAltitude(DodgeAltitudeOffset)
      else
         SetAltitude(DesiredControlAltitude+(DropAI_Closing and ControlAltitudeOffset or 0))
      end
      SixDoF_Update(I)
   end

   ShieldManager:Tick(I)
end
