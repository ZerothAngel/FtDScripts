--@ quadraticintercept
-- UnifiedMissile implementation
UnifiedMissile = {}

function UnifiedMissile.create(Config)
   local self = {}

   -- General parameters
   self.SpecialAttackElevation = Config.SpecialAttackElevation -- number
   self.MinimumAltitude = Config.MinimumAltitude -- number

   -- Note: "RelativeTo" parameters should be one of
   -- 0 - Absolute
   -- 1 - Relative to target's altitude
   -- 2 - Relative to target's sea depth
   -- 3 - Relative to target's ground

   -- Closing parameters
   self.ClosingDistance = Config.ClosingDistance -- number
   self.ClosingAboveSeaLevel = Config.ClosingAboveSeaLevel -- bool
   self.ClosingElevation = Config.ClosingElevation -- number
   self.ClosingAltitude = Config.ClosingAltitude -- number or nil
   self.ClosingAltitudeRelativeTo = Config.ClosingAltitudeRelativeTo -- number
   self.Evasion = Config.Evasion -- { number, number } or nil

   -- Special maneuver parameters
   self.SpecialManeuverDistance = Config.SpecialManeuverDistance -- number
   self.SpecialManeuverAboveSeaLevel = Config.SpecialManeuverAboveSeaLevel -- bool
   self.SpecialManeuverElevation = Config.SpecialManeuverElevation -- number
   self.SpecialManeuverAltitude = Config.SpecialManeuverAltitude -- number or nil
   self.SpecialManeuverAltitudeRelativeTo = Config.SpecialManeuverAltitudeRelativeTo -- number

   -- Terminal parameters
   self.TerminalDistance = Config.TerminalDistance -- number

   -- Terrain hugging parameters
   self.LookAheadTime = Config.LookAheadTime -- number
   self.LookAheadResolution = Config.LookAheadResolution -- number

   -- Methods (because no setmetatable)
   self.GetTerrainHeight = UnifiedMissile.GetTerrainHeight
   self.ModifyAltitude = UnifiedMissile.ModifyAltitude
   self.SpecialAttackAltitude = UnifiedMissile.SpecialAttackAltitude
   self.SpecialAttack = UnifiedMissile.SpecialAttack
   self.SetTarget = UnifiedMissile.SetTarget
   self.Guide = UnifiedMissile.Guide

   return self
end

-- Return highest terrain seen within look-ahead distance
function UnifiedMissile:GetTerrainHeight(I, Position, Velocity, MaxDistance)
   if not MaxDistance then MaxDistance = math.huge end

   local LookAheadResolution = self.LookAheadResolution
   if LookAheadResolution <= 0 then return -500 end

   local Height = -500
   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = PlanarVelocity.magnitude
   local Direction = PlanarVelocity / Speed

   local Distance = math.min(Speed * self.LookAheadTime, MaxDistance)

   for d = 0,Distance-1,LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return Height
end

-- Modify an altitude according to RelativeTo
function UnifiedMissile:ModifyAltitude(Altitude, RelativeTo)
   if RelativeTo == 1 then
      -- Relative to target's absolute altitude [-500, whatever)
      return self.TargetAltitude + Altitude
   elseif RelativeTo == 2 then
      -- Relative to target's sea depth [-500, 0]
      return self.TargetDepth + Altitude
   elseif RelativeTo == 3 then
      -- Relative to target's ground [0, whatever)
      return self.TargetGround + Altitude
   else
      -- Absolute (no modification)
      return Altitude
   end
end

-- Modify altitude according to flavor
function UnifiedMissile:SpecialAttackAltitude(I, Position, Velocity, AboveSeaLevel, Elevation, Altitude, RelativeTo, MaxDistance)
   local Height = self:GetTerrainHeight(I, Position, Velocity, MaxDistance)
   if AboveSeaLevel then
      -- Constrain terrain hugging to sea level
      Height = math.max(Height, 0)
   end
   Height = Height + Elevation

   if not Altitude then
      -- Always relative to terrain.
      return Height
   else
      -- Relative to target, hugging terrain if necessary.
      return math.max(self:ModifyAltitude(Altitude, RelativeTo), Height)
   end
end

-- Modification of the aim point to give the missile its flavor
function UnifiedMissile:SpecialAttack(I, Position, Velocity, AimPoint, Now, Offset)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   local TerminalDistance = self.TerminalDistance
   if GroundDistance < TerminalDistance then
      -- Always return real aim point when within terminal distance
      return AimPoint
   elseif GroundDistance < self.SpecialManeuverDistance then
      -- Begin special maneuver, if any. Generally a pop-up or pop-under.
      local GroundDirection = GroundOffset / GroundDistance
      local ToTerminal = GroundDistance - TerminalDistance

      -- New aim point is toward target at edge of terminal distance
      local NewAimPoint = Position + GroundDirection * ToTerminal
      NewAimPoint.y = self:SpecialAttackAltitude(I, Position, Velocity, self.SpecialManeuverAboveSeaLevel, self.SpecialManeuverElevation, self.SpecialManeuverAltitude, self.SpecialManeuverAltitudeRelativeTo, ToTerminal)

      return NewAimPoint
   else
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = Position + GroundDirection * self.ClosingDistance
      NewAimPoint.y = self:SpecialAttackAltitude(I, Position, Velocity, self.ClosingAboveSeaLevel, self.ClosingElevation, self.ClosingAltitude, self.ClosingAltitudeRelativeTo)

      -- Perform horizontal evasion, if any
      local Evasion = self.Evasion
      if Evasion then
         local Perp = Vector3.Cross(GroundDirection, Vector3.up)
         NewAimPoint = NewAimPoint + Perp * Evasion[1] * (2 * Mathf.PerlinNoise(Evasion[2] * Now, Offset) - 1)
      end

      return NewAimPoint
   end
end

function UnifiedMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   local TargetAltitude = TargetPosition.y

   self.TargetAltitude = TargetAltitude -- Raw altitude
   self.TargetDepth = math.min(TargetAltitude, 0) -- When below sea level
   self.TargetGround = math.max(I:GetTerrainAltitudeForPosition(TargetPosition), 0) -- When above sea level

   -- For now, performing the special attack is solely based on the target's
   -- elevation above sea level.
   self.DoSpecialAttack = (TargetAltitude - self.TargetGround) <= self.SpecialAttackElevation
end

function UnifiedMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile, Now)
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local AimPoint = QuadraticIntercept(MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)

   local MinimumAltitude = self.MinimumAltitude
   if MissilePosition.y < MinimumAltitude then
      -- Below minimum altitude, head straight up
      AimPoint = Vector3(MissilePosition.x, MinimumAltitude+1000, MissilePosition.z)
   elseif self.DoSpecialAttack then
      local Offset = TransceiverIndex * 37 + MissileIndex -- Used for Perlin noise lookup
      AimPoint = self:SpecialAttack(I, MissilePosition, MissileVelocity, AimPoint, Now, Offset)
   end

   return AimPoint
end
