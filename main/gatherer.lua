--! gatherer
--@ getselfinfo firstrun periodic
--@ threedofspinner altitudecontrol gatherer-ai
-- Gatherer main
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
GathererAI = Periodic.create(AI_UpdateRate, GathererAI_Update)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         GathererAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      end

      ThreeDoFSpinner_Update(I)
   end
end
