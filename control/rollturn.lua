--@ commons normalizebearing getvectorangle sign
-- RollTurn module
RollTurnControl = {}

function RollTurn.SetHeading(Heading)
   local AngleBeforeRoll = RollTurn.AngleBeforeRoll
   if AngleBeforeRoll then
      Heading = Heading % 360
      -- I loathe having to calculate this again, but eh.
      local Bearing = NormalizeBearing(Heading - GetVectorAngle(C:ForwardVector()))
      local AbsBearing = math.abs(Bearing)
      local MaxRollAngle,RollAngleGain = RollTurn.MaxRollAngle,RollTurn.RollAngleGain
      if AbsBearing > AngleBeforeRoll then
         local RollAngle = RollAngleGain and math.min(MaxRollAngle, (AbsBearing - AngleBeforeRoll) * RollAngleGain) or MaxRollAngle
         RollTurnControl.SetRoll(-Sign(Bearing) * RollAngle)
      else
         RollTurnControl.SetRoll(0)
      end
   end
   RollTurnControl.SetHeading(Heading)
end

function RollTurn.ResetHeading()
   RollTurnControl.ResetHeading()
   RollTurnControl.SetRoll(0)
end

function RollTurn.SetRoll(Angle)
   if not RollTurn.AngleBeforeRoll then
      RollTurnControl.SetRoll(Angle)
   end
end
