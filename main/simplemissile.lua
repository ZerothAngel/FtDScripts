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

-- Returns solution(s) to a quadratic equation in table form.
-- Table will be empty if solutions are imaginary or invalid.
function QuadraticSolver(a, b, c)
   if a == 0 then
      -- Actually linear
      if b ~= 0 then
         return { -c / b }
      else
         return {} -- Division by zero...
      end
   else
      -- Discriminant
      local disc = b * b - 4 * a * c
      local twoA = 2 * a
      if disc < 0 then
         return {} -- Imaginary
      elseif disc == 0 then
         -- Single solution
         return { -b / twoA }
      else
         -- Two solutions
         local root = Mathf.Sqrt(disc)
         local t1 = (-b + root) / twoA
         local t2 = (-b - root) / twoA
         return { t1, t2 }
      end
   end
end

-- Quadratic intercept formula
function QuadraticIntercept(Position, Velocity, Target, TargetVelocity)
   local Offset = Target - Position
   -- Apparently you can apply binomial expansion to vectors
   -- ...as long as it's 2nd degree only
   local a = Vector3.Dot(TargetVelocity, TargetVelocity) - Vector3.Dot(Velocity, Velocity)  -- aka difference of squares of velocity magnitudes
   local b = 2 * Vector3.Dot(Offset, TargetVelocity)
   local c = Vector3.Dot(Offset, Offset) -- Offset.magnitude squared
   local Solutions = QuadraticSolver(a, b, c)
   local InterceptTime = 1
   -- Pick smallest positive intercept time
   if #Solutions == 1 then
      local t = Solutions[1]
      if t > 0 then InterceptTime = t end
   elseif #Solutions == 2 then
      local t1 = Solutions[1]
      local t2 = Solutions[2]
      if t1 < t2 then
         if t1 > 0 then
            InterceptTime = t1
         elseif t2 > 0 then
            InterceptTime = t2
         end
      else
         if t2 > 0 then
            InterceptTime = t2
         elseif t1 > 0 then
            InterceptTime = t1
         end
      end
   end

   return Target + TargetVelocity * InterceptTime
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
               local AimPoint = QuadraticIntercept(MissilePosition,
                                                   MissileVelocity,
                                                   TargetAimPoint,
                                                   TargetVelocity)

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
