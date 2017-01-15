--! dropquad
--@ commons firstrun periodic
--@ shieldmanager threedofspinner altitudecontrol threedof drop-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
DropAI = Periodic.create(AI_UpdateRate, DropAI_Update)

Control_Reset = ThreeDoF_Reset

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I, true)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         DropAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         ThreeDoF_Reset()
         DodgeAltitudeOffset = nil
      end

      if DodgeAltitudeOffset then
         AdjustAltitude(DodgeAltitudeOffset)
      else
         SetAltitude(DesiredControlAltitude+(DropAI_Closing and ControlAltitudeOffset or 0))
      end
      ThreeDoFSpinner_Update(I)
      ThreeDoF_Update(I)
   else
      ThreeDoFSpinner_Disable(I)
   end

   ShieldManager:Tick(I)
end
