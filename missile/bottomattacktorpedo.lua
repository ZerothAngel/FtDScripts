--@ quadraticintercept
-- BottomAttackTorpedo implementation
BottomAttackTorpedo = {}

function BottomAttackTorpedo.create()
   local self = {}
   self.SetTarget = BottomAttackTorpedo.SetTarget
   self.Guide = BottomAttackTorpedo.Guide
   return self
end

-- BottomAttackTorpedo static methods

-- Return highest terrain seen
function BottomAttackTorpedo.GetTerrainHeight(I, Position, Velocity)
   if BA_LookAheadResolution <= 0 then return -500 end

   local Height = -500
   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = PlanarVelocity.magnitude
   local Direction = PlanarVelocity / Speed

   local Distance = Speed * LookAheadTime
   for d = 0,Distance-1,BA_LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return Height
end

function BottomAttackTorpedo.BottomAttack(I, Position, Velocity, AimPoint, TargetDepth)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   if GroundDistance < TerminalDistance then
      -- Always return real aim point when within terminal distance
      return AimPoint
   else
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = Position + GroundDirection * CruisingDistance
      local Height = BottomAttackTorpedo.GetTerrainHeight(I, Position, Velocity)
      NewAimPoint.y = math.max(TargetDepth - CruisingDepth, Height + MinimumSeabedAltitude)
      return NewAimPoint
   end
end

-- BottomAttackTorpedo instance methods

function BottomAttackTorpedo:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   self.TargetDepth = math.min(TargetPosition.y, 0)
end
      
function BottomAttackTorpedo:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local AimPoint = QuadraticIntercept(MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)

   AimPoint = BottomAttackTorpedo.BottomAttack(I, MissilePosition, MissileVelocity, AimPoint, self.TargetDepth)

   return AimPoint
end
