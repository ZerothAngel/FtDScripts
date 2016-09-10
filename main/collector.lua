--! collector
--@ getselfinfo firstrun periodic
--@ threedofspinner altitudecontrol yawthrottle collector-ai
-- Collector main
Quadcopter = Periodic.create(Quadcopter_UpdateRate, Altitude_Control, 1)
CollectorAI = Periodic.create(AI_UpdateRate, CollectorAI_Update)

Control_Reset = YawThrottle_Reset

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Quadcopter:Tick(I)

      if ActivateWhen[I.AIMode] then
         CollectorAI:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()

         YawThrottle_Update(I)
      else
         CollectorDestinations = {}
      end

      ThreeDoFSpinner_Update(I)
   end
end
