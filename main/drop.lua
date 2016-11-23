--! drop
--@ getselfinfo firstrun periodic
--@ shieldmanager altitudecontrol sixdof drop-ai
ShieldManager = Periodic.create(ShieldManager_UpdateRate, ShieldManager_Control, 2)
Hover = Periodic.create(Hover_UpdateRate, Altitude_Control, 1)
DropAI = Periodic.create(AI_UpdateRate, DropAI_Update)

Control_Reset = SixDoF_Reset

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      if ActivateWhen[I.AIMode] then
         DropAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         SixDoF_Reset()
      end

      SetAltitude(DesiredControlAltitude)
      SixDoF_Update(I)
   end

   ShieldManager:Tick(I)
end
