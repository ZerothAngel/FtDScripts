--! simplemissile
--@ periodic
-- SimpleMissile module
TargetInfo = nil

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

function PopUp(I, Position, Velocity, AimPoint)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   if GroundDistance < PopUpTerminalDistance then
      return AimPoint
   elseif GroundDistance < PopUpDistance then
      local GroundDirection = GroundOffset / GroundDistance
      local ToTerminal = GroundDistance - PopUpTerminalDistance
      local NewAimPoint = Position + GroundDirection * ToTerminal
      local Height = GetTerrainHeight(I, Position, Velocity, ToTerminal)
      NewAimPoint.y = Height + PopUpAltitude
      return NewAimPoint
   elseif Position.y > 0 then
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = Position + GroundDirection * PopUpSkimDistance
      local Height = GetTerrainHeight(I, Position, Velocity, PopUpSkimDistance)
      NewAimPoint.y = Height + PopUpSkimAltitude
      return NewAimPoint
   else
      -- Below the surface, head straight up
      return Vector3(Position.x, PopUpSkimAltitude, Position.z)
   end
end

function SimpleMissile_Update(I)
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
                  AimPoint = PopUp(I, MissilePosition, MissileVelocity,
                                   AimPoint)
               end

               I:SetLuaControlledMissileAimPoint(i, j, AimPoint.x, AimPoint.y, AimPoint.z)
            end
         end
      end
   end
end

Main = Periodic.create(10, SimpleMissile_Update)

function Update(I)
   Main:Tick(I)
end
