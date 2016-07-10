--@ quadraticintercept
-- JavelinMissile implementation
JavelinMissile = {}

function JavelinMissile.create()
   local self = {}
   self.SetTarget = JavelinMissile.SetTarget
   self.Guide = JavelinMissile.Guide
   return self
end

function JavelinMissile.TopAttack(I, Position, Velocity, AimPoint, TargetGround, Time, Offset)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   if GroundDistance < TerminalDistance then
      -- Always return real aim point when within terminal distance
      return AimPoint
   else
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = Position + GroundDirection * JavelinClosingDistance
      -- TODO Hmmm... this is almost the same as BottomAttackTorpedo but without the
      -- terrain logic.
      NewAimPoint.y = TargetGround + JavelinClosingHeight
      if JavelinEvasion then
         local Perp = Vector3.Cross(GroundDirection, Vector3.up)
         NewAimPoint = NewAimPoint + Perp * JavelinEvasion[1] * (2 * Mathf.PerlinNoise(JavelinEvasion[2] * Time, Offset) - 1)
      end
      return NewAimPoint
   end
end

-- JavelinMissile instance methods

function JavelinMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   self.Time = I:GetTimeSinceSpawn()
   self.TargetGround = math.max(I:GetTerrainAltitudeForPosition(TargetPosition), 0)
   self.DoTopAttack = (TargetPosition.y - self.TargetGround) <= JavelinAirTargetAltitude
end

function JavelinMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local AimPoint = QuadraticIntercept(MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)

   if MissilePosition.y < JavelinMinimumAltitude then
      -- Below the surface, head straight up
      AimPoint = Vector3(MissilePosition.x, JavelinMinimumAltitude+1000, MissilePosition.z)
   elseif self.DoTopAttack then
      local Offset = TransceiverIndex * 37 + MissileIndex
      AimPoint = JavelinMissile.TopAttack(I, MissilePosition, MissileVelocity,
                                          AimPoint, self.TargetGround,
                                          self.Time, Offset)
   end

   return AimPoint
end
