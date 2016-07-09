--@ quadraticintercept
-- JavelinMissile implementation
JavelinMissile = {}

function JavelinMissile.create()
   local self = {}
   self.SetTarget = JavelinMissile.SetTarget
   self.Guide = JavelinMissile.Guide
   return self
end

-- JavelinMissile instance methods

function JavelinMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   self.TargetGround = math.max(I:GetTerrainAltitudeForPosition(TargetPosition), 0)
   self.DoTopAttack = (TargetPosition.y - self.TargetGround) <= JavelinAirTargetAltitude
end

function JavelinMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)
   -- Calculate standard aim point
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local AimPoint = QuadraticIntercept(MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)

   -- Then modify according to ground distance from target/launcher
   local NewTarget = Vector3(AimPoint.x, MissilePosition.y, AimPoint.z)
   local GroundOffset = NewTarget - MissilePosition
   local GroundDistance = GroundOffset.magnitude

   if GroundDistance < JavelinTerminalDistance or not self.DoTopAttack then
      -- Always return real aim point when within terminal distance
      return AimPoint
   else
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = MissilePosition + GroundDirection * JavelinClosingDistance
      -- TODO Hmmm... this is almost the same as BottomAttackTorpedo but without the
      -- terrain logic.
      NewAimPoint.y = self.TargetGround + JavelinClosingHeight
      return NewAimPoint
   end
end
