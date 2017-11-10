--@ commonstargets commons movingaverage
-- Target acceleration measurement
TargetAccel_TargetStates = {}

function CalculateTargetAcceleration(NumSamples)
   local NewTargetStates = {}

   local Now = C:Now()
   for _,Target in pairs(C:Targets()) do
      local Velocity = Target.Velocity

      local State = TargetAccel_TargetStates[Target.Id]
      if State and (State.LastTime + 1) > Now then
         local dV = Velocity - State.LastVelocity
         local dT = Now - State.LastTime

         State.LastTime = Now
         State.LastVelocity = Velocity
         State.AccelMA:AddSample(dV / dT)
         State.LastAcceleration = State.AccelMA.Average
      else
         -- New target or timed out
         State = {
            LastTime = Now,
            LastVelocity = Velocity,
            AccelMA = MovingAverage.new(NumSamples, Vector3.zero),
            LastAcceleration = Vector3.zero,
         }
      end

      NewTargetStates[Target.Id] = State
      Target.Acceleration = State.LastAcceleration
   end

   TargetAccel_TargetStates = NewTargetStates
end
