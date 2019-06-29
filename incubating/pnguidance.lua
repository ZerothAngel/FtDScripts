PNGuidance = {}

function PNGuidance.new(Config)
   local self = {}

   self.Gain = Config.Gain
   self.OneTurnAngle = math.cos(math.rad(Config.OneTurnAngle))

   self.Guide = PNGuidance.Guide

   return self
end

function PNGuidance:Guide(I, TransceiverIndex, MissileIndex, Target, Missile, MissileState)
   local AimPoint = nil

   local TargetPosition = Target.AimPoint
   local MissilePosition = Missile.Position
   local Now = Missile.TimeSinceLaunch

   local PreviousTargetPosition = MissileState.PreviousTargetPosition
   local PreviousMissilePosition = MissileState.PreviousMissilePosition
   local PreviousTime = MissileState.PreviousTime

   if PreviousTargetPosition and PreviousMissilePosition and PreviousTime then
      local Offset = TargetPosition - MissilePosition
      local MissileVelocity = Missile.Velocity
      local TargetCosAngle = Vector3.Dot(Offset.normalized, MissileVelocity.normalized)

      if TargetCosAngle < self.OneTurnAngle then
         -- One-turn
         AimPoint = TargetPosition
      else
         local TimeStep = Now - PreviousTime

         local PreviousOffset = PreviousTargetPosition - PreviousMissilePosition
         local RelativeVelocity = Offset - PreviousOffset
         local Omega = Vector3.Cross(Offset, RelativeVelocity) / Vector3.Dot(Offset, Offset)
         local Direction = MissileVelocity.normalized
         local Acceleration = Vector3.Cross(Direction * -self.Gain * RelativeVelocity.magnitude, Omega)

         AimPoint = MissilePosition + MissileVelocity * TimeStep + Acceleration * 0.5
      end
   end
   
   MissileState.PreviousTargetPosition = TargetPosition
   MissileState.PreviousMissilePosition = MissilePosition
   MissileState.PreviousTime = Now

   return AimPoint
end
