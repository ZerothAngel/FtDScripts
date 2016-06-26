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

function PopUp(Position, AimPoint)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   if GroundDistance < PopUpTerminalDistance then
      return AimPoint
   elseif GroundDistance < PopUpDistance then
      local GroundDirection = GroundOffset / GroundDistance
      local ToTerminal = GroundDistance - PopUpTerminalDistance
      local NewAimPoint = Position + GroundDirection * ToTerminal
      NewAimPoint.y = PopUpAltitude
      return NewAimPoint
   elseif Position.y > 0 then
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = Position + GroundDirection * PopUpSkimDistance
      NewAimPoint.y = PopUpSkimAltitude
      return NewAimPoint
   else
      -- Below the surface, head straight up
      return Vector3(Position.x, PopUpSkimAltitude, Position.z)
   end
end

function SimpleMissile_Update(I)
   if GetTarget(I) then
      for i = 0,I:GetLuaTransceiverCount() do
         for j = 0,I:GetLuaControlledMissileCount(i) do
            local Missile = I:GetLuaControlledMissileInfo(i, j)
            if Missile.Valid then
               local AimPoint = Guide(Missile.Position, Missile.Velocity,
                                      TargetInfo.AimPointPosition,
                                      TargetInfo.Velocity)

               if TargetInfo.Position.y <= AirTargetAltitude then
                  AimPoint = PopUp(Missile.Position, AimPoint)
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
