--@ pronav
-- PN guided missile
ProNavMissile = {}

function ProNavMissile.create(Config, UpdateRate)
   local self = {}

   self.Gain = Config.Gain
   self.TimeStep = UpdateRate / 40 -- Broken
   self.OneTurnTime = Config.OneTurnTime
   self.OneTurnAngle = math.cos(math.rad(Config.OneTurnAngle))
   self.DetonationRange = Config.DetonationRange
   self.DetonationAngle = math.cos(math.rad(Config.DetonationAngle))

   self.SetTarget = ProNavMissile.SetTarget
   self.Guide = ProNavMissile.Guide

   return self
end

function ProNavMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   -- Nothing to do
end

function ProNavMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile, MissileState)
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local TargetVector = TargetAimPoint - MissilePosition
   local TargetRange = TargetVector.magnitude
   -- Calculate angle between missile velocity and target vector
   local CosAngle = Vector3.Dot(TargetVector / TargetRange, MissileVelocity.normalized)
   -- Check if we should detonate
   if TargetRange <= self.DetonationRange and CosAngle <= self.DetonationAngle then
      I:DetonateLuaControlledMissile(TransceiverIndex, MissileIndex)
      return TargetAimPoint -- Don't really care at this point
   end
   -- Perform a "one turn" maneuver if newly-launched
   if Missile.TimeSinceLaunch <= self.OneTurnTime and CosAngle < self.OneTurnAngle then
      -- Just turn straight toward target
      return TargetAimPoint
   end
   return ProNav(self, MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)
end
