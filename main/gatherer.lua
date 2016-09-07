--! gatherer
--@ getselfinfo firstrun periodic
--@ threedofspinner altitudecontrol yawthrottle gatherer-ai
-- Gatherer main
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
GathererAI = Periodic.create(AI_UpdateRate, GathererAI_Update)

Control_Reset = YawThrottle_Reset

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
