--! basictorpedo
--@ quadraticintercept gettargetinfo periodic
-- Return highest terrain seen
function GetTerrainHeight(I, Position, Velocity)
   if LookAheadResolution <= 0 then return -500 end

   local Height = -500
   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = PlanarVelocity.magnitude
   local Direction = PlanarVelocity / Speed

   local Distance = Speed * LookAheadTime
   for d = 0,Distance-1,LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return Height
end

function BottomAttack(I, Position, Velocity, AimPoint, TargetDepth)
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
      local Height = GetTerrainHeight(I, Position, Velocity)
      NewAimPoint.y = math.max(TargetDepth - CruisingDepth, Height + MinimumSeabedAltitude)
      return NewAimPoint
   end
end

-- Main update loop
function BasicTorpedo_Update(I)
   local Time = I:GetTimeSinceSpawn()

   if GetTargetInfo(I) then
      local TargetPosition = TargetInfo.Position
      local TargetAimPoint = TargetInfo.AimPointPosition
      local TargetVelocity = TargetInfo.Velocity
      local TargetDepth = math.min(TargetPosition.y, 0)

      for i = 0,I:GetLuaTransceiverCount()-1 do
         for j = 0,I:GetLuaControlledMissileCount(i)-1 do
            local Missile = I:GetLuaControlledMissileInfo(i, j)
            if Missile.Valid then
               local MissilePosition = Missile.Position
               local MissileVelocity = Missile.Velocity
               local AimPoint = QuadraticIntercept(MissilePosition,
                                                   MissileVelocity,
                                                   TargetAimPoint,
                                                   TargetVelocity)

               AimPoint = BottomAttack(I, MissilePosition, MissileVelocity,
                                       AimPoint, TargetDepth)

               I:SetLuaControlledMissileAimPoint(i, j, AimPoint.x, AimPoint.y, AimPoint.z)
            end
         end
      end
   end
end

BasicTorpedo = Periodic.create(UpdateRate, BasicTorpedo_Update)

function Update(I)
   BasicTorpedo:Tick(I)
end
