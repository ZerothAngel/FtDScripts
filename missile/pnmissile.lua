--@ pronav
-- PN guided missile
ProNavMissile = {}

function ProNavMissile.create(Gain, UpdateRate)
   local self = {}

   self.Gain = Gain
   self.TimeStep = UpdateRate / 40

   self.SetTarget = ProNavMissile.SetTarget
   self.Guide = ProNavMissile.Guide

   return self
end

function ProNavMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   -- Nothing to do
end

function ProNavMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)
   return ProNav(self, Missile.Position, Missile.Velocity, TargetAimPoint, TargetVelocity)
end
