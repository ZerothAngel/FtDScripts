--@ deepcopy
PNGuidance = {}

function PNGuidance.new(Config)
   local self = deepcopy(Config)

   self.OneTurnAngle = math.cos(math.rad(self.OneTurnAngle))

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

      AimPoint = TargetPosition

      local IsTerminal = MissileState.IsTerminal
      if not IsTerminal and TargetCosAngle >= self.OneTurnAngle then
         MissileState.IsTerminal = true
      end
      if IsTerminal then
         local TimeStep = Now - PreviousTime

         local PreviousOffset = PreviousTargetPosition - PreviousMissilePosition
         local RelativeVelocity = Offset - PreviousOffset
         local Omega = Vector3.Cross(Offset, RelativeVelocity) / Vector3.Dot(Offset, Offset)
         local Direction = MissileVelocity.normalized
         local Acceleration = Vector3.Cross(Direction * -self.Gain * RelativeVelocity.magnitude, Omega)
         if Target.Acceleration then
            -- Add augmented term
            local TargetAcceleration = Target.Acceleration * TimeStep
            -- Project onto LOS
            local LOS = Offset.normalized
            local Proj = LOS * Vector3.Dot(TargetAcceleration, LOS)
            -- And use rejection (which should be ortho LOS) for augmented term
            Acceleration = Acceleration + (TargetAcceleration - Proj) * self.Gain * 0.5
         end

         AimPoint = MissilePosition + MissileVelocity * TimeStep + Acceleration * 0.5
      end
   end
   
   MissileState.PreviousTargetPosition = TargetPosition
   MissileState.PreviousMissilePosition = MissilePosition
   MissileState.PreviousTime = Now

   return AimPoint
end
