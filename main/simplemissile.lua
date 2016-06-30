--! simplemissile
--@ periodic
-- SimpleMissile module
TargetInfo = nil

-- Custom GetTarget since we only care about TargetInfo rather than TargetPositionInfo
function GetTarget(I)
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         TargetInfo = I:GetTargetInfo(mindex, tindex)
         if TargetInfo.Valid then return true end
      end
   end
   TargetInfo = nil
   return false
end

-- Standard ballistic (i.e. assumes constant projectile velocity) formula.
-- Given that we definitively know the target's velocity, it works great.
function Guide(Position, Velocity, AimPoint, TargetVelocity)
   local Offset = AimPoint - Position
   local Distance = Offset.magnitude
   local Direction = Offset / Distance -- aka Offset.normalized
   local RelativeVelocity = Velocity - TargetVelocity
   local RelativeSpeed = Vector3.Dot(RelativeVelocity, Direction)
   local InterceptTime = 1
   if RelativeSpeed > 0.0 then
      InterceptTime = Distance / RelativeSpeed
   end

   return AimPoint + TargetVelocity * InterceptTime
end

-- Samples terrain in direction of Velocity up to (and including) Distance meters away.
-- Return highest terrain seen (or 0 if all underwater)
function GetTerrainHeight(I, Position, Velocity, Distance)
   if LookAheadResolution <= 0 then return 0 end

   local Height = -500
   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Direction = PlanarVelocity.normalized

   for d = 0,Distance-1,LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return math.max(Height, 0)
end

-- Modifies AimPoint for pop-up behavior
function PopUp(I, Position, Velocity, AimPoint, TargetGround, Time, Offset)
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
      local Height = GetTerrainHeight(I, Position, Velocity, ToTerminal)
      NewAimPoint.y = math.max(TargetGround + PopUpAltitude, Height + PopUpSkimAltitude)
      return NewAimPoint
   elseif Position.y > MinimumAltitude then
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      -- Simply hug the surface by calculating the aim point some meters (PopUpSkimDistance) out
      local NewAimPoint = Position + GroundDirection * PopUpSkimDistance
      local Height = GetTerrainHeight(I, Position, Velocity, PopUpSkimDistance)
      NewAimPoint.y = Height + PopUpSkimAltitude
      if Evasion then
         local Perp = Vector3.Cross(GroundDirection, Vector3.up)
         NewAimPoint = NewAimPoint + Perp * Evasion[1] * (2 * Mathf.PerlinNoise(Evasion[2] * Time, Offset) - 1)
      end
      return NewAimPoint
   else
      -- Below the surface, head straight up
      return Vector3(Position.x, PopUpSkimAltitude, Position.z)
   end
end

-- Main update loop
function SimpleMissile_Update(I)
   local Time = I:GetTimeSinceSpawn()

   if GetTarget(I) then
      local TargetPosition = TargetInfo.Position
      local TargetAimPoint = TargetInfo.AimPointPosition
      local TargetVelocity = TargetInfo.Velocity
      local TargetGround = I:GetTerrainAltitudeForPosition(TargetPosition)
      TargetGround = math.max(TargetGround, 0)
      DoPopUp = (TargetPosition.y - TargetGround) <= AirTargetAltitude

      for i = 0,I:GetLuaTransceiverCount()-1 do
         for j = 0,I:GetLuaControlledMissileCount(i)-1 do
            local Missile = I:GetLuaControlledMissileInfo(i, j)
            if Missile.Valid then
               local MissilePosition = Missile.Position
               local MissileVelocity = Missile.Velocity
               local AimPoint = Guide(MissilePosition, MissileVelocity,
                                      TargetAimPoint, TargetVelocity)

               if DoPopUp then
                  local Offset = i * 37 + j
                  AimPoint = PopUp(I, MissilePosition, MissileVelocity,
                                   AimPoint, TargetGround, Time, Offset)
               elseif MissilePosition.y < MinimumAltitude then
                  AimPoint = Vector3(MissilePosition.x, MinimumAltitude, MissilePosition.z)
               end

               I:SetLuaControlledMissileAimPoint(i, j, AimPoint.x, AimPoint.y, AimPoint.z)
            end
         end
      end
   end
end

SimpleMissile = Periodic.create(UpdateRate, SimpleMissile_Update)

function Update(I)
   SimpleMissile:Tick(I)
end
