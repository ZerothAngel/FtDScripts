--@ quadraticintercept
-- PopUpMissile implementation
PopUpMissile = {}

function PopUpMissile.create()
   local self = {}
   self.SetTarget = PopUpMissile.SetTarget
   self.Guide = PopUpMissile.Guide
   return self
end

-- PopUpMissile static methods

-- Samples terrain in direction of Velocity up to (and including) Distance meters away.
-- Return highest terrain seen (or 0 if all underwater)
function PopUpMissile.GetTerrainHeight(I, Position, Velocity, Distance)
   if PU_LookAheadResolution <= 0 then return 0 end

   local Height = -500
   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Direction = PlanarVelocity.normalized

   for d = 0,Distance-1,PU_LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return math.max(Height, 0)
end

-- Modifies AimPoint for pop-up behavior
function PopUpMissile.PopUp(I, Position, Velocity, AimPoint, TargetGround, Time, Offset)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   if GroundDistance < PopUpTerminalDistance then
      -- Always return real aim point when within terminal distance
      return AimPoint
   elseif GroundDistance < PopUpDistance then
      -- Begin pop-up
      local GroundDirection = GroundOffset / GroundDistance
      local ToTerminal = GroundDistance - PopUpTerminalDistance
      -- New aim point is toward target at edge of terminal distance
      local NewAimPoint = Position + GroundDirection * ToTerminal
      local Height = PopUpMissile.GetTerrainHeight(I, Position, Velocity, ToTerminal)
      NewAimPoint.y = math.max(TargetGround + PopUpAltitude, Height + PopUpSkimAltitude)
      return NewAimPoint
   elseif Position.y > MinimumAltitude then
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      -- Simply hug the surface by calculating the aim point some meters (PopUpSkimDistance) out
      local NewAimPoint = Position + GroundDirection * PopUpSkimDistance
      local Height = PopUpMissile.GetTerrainHeight(I, Position, Velocity, PopUpSkimDistance)
      NewAimPoint.y = Height + PopUpSkimAltitude
      if Evasion then
         local Perp = Vector3.Cross(GroundDirection, Vector3.up)
         NewAimPoint = NewAimPoint + Perp * Evasion[1] * (2 * Mathf.PerlinNoise(Evasion[2] * Time, Offset) - 1)
      end
      return NewAimPoint
   else
      -- Below the surface, head straight up
      return Vector3(Position.x, MinimumAltitude+PopUpSkimDistance, Position.z)
   end
end

-- PopUpMissile instance methods

function PopUpMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   self.Time = I:GetTimeSinceSpawn()
   self.TargetGround = math.max(I:GetTerrainAltitudeForPosition(TargetPosition), 0)
   self.DoPopUp = (TargetPosition.y - self.TargetGround) <= AirTargetAltitude
end

function PopUpMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile)
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local AimPoint = QuadraticIntercept(MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)

   if self.DoPopUp then
      local Offset = TransceiverIndex * 37 + MissileIndex
      AimPoint = PopUpMissile.PopUp(I, MissilePosition, MissileVelocity,
                                    AimPoint, self.TargetGround, self.Time,
                                    Offset)
   elseif MissilePosition.y < MinimumAltitude then
      AimPoint = Vector3(MissilePosition.x, MinimumAltitude, MissilePosition.z)
   end

   return AimPoint
end
