--! dropquad
--@ commons firstrun periodic
--@ shieldmanager threedofspinner altitudecontrol threedof drop-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
DropAI = Periodic.create(AI_UpdateRate, DropAI_Update)

Control_Reset = ThreeDoF_Reset

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      C = Commons.create(I)

      if FirstRun then FirstRun(I) end

      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         DropAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         ThreeDoF_Reset()
      end

      SetAltitude(DesiredControlAltitude)
      ThreeDoFSpinner_Update(I)
      ThreeDoF_Update(I)
   else
      ThreeDoFSpinner_Disable(I)
   end

   ShieldManager:Tick(I)
end
