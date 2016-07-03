--! dodgetest
--@ yawthrottle commons quadraticsolver spairs periodic
DodgeDirections = { Vector3.left, Vector3.right, Vector3.left, Vector3.right }

-- Returns impact point on XZ plane at given altitude
-- Returns nil if no impact on the plane
function PredictImpact(I, Altitude, Projectile)
   local ProjectilePosition = Projectile.Position
   local ProjectileAltitude = ProjectilePosition.y
   local ProjectileVelocity = Projectile.Velocity
   local Gravity = I:GetGravityForAltitude(ProjectileAltitude).y

   local a = 0.5 * Gravity
   local b = ProjectileVelocity.y
   local c = ProjectileAltitude - Altitude
   local Solutions = QuadraticSolver(a, b, c)
   local ImpactTime = nil
   if #Solutions == 1 then
      local t = Solutions[1]
      if t > 0 then ImpactTime = t end
   elseif #Solutions == 2 then
      local t1 = Solutions[1]
      local t2 = Solutions[2]
      if t1 < t2 then
         if t1 > 0 then
            ImpactTime = t1
         elseif t2 > 0 then
            ImpactTime = t2
         end
      else
         if t2 > 0 then
            ImpactTime = t2
         elseif t1 > 0 then
            ImpactTime = t1
         end
      end
   end

   if ImpactTime then
      local ImpactPoint = ProjectilePosition + ProjectileVelocity * ImpactTime
      -- Don't bother calculating gravity since this is the time it
      -- impacts the plane anyway
      ImpactPoint.y = Altitude
      return ImpactPoint, ImpactTime
   else
      return nil
   end
end

-- Return predicted impact local quadrant. Quadrants are 1-4 clockwise
-- starting with pos X/pos Z quadrant.
function PredictImpactQuadrant(I, Velocity, Projectile)
   local ImpactPoint,ImpactTime = PredictImpact(I, Altitude, Projectile)
   if not ImpactPoint then return nil end

   -- Move it to local frame of reference
   ImpactPoint = ImpactPoint - (CoM + Velocity * ImpactTime)
   ImpactPoint = Quaternion.Euler(0, -Yaw, 0) * ImpactPoint

   -- TODO Constrain by self dimensions

   if ImpactPoint.x >= 0 then
      if ImpactPoint.z >= 0 then
         return 1,ImpactTime
      else
         return 2,ImpactTime
      end
   else
      if ImpactPoint.z >= 0 then
         return 4,ImpactTime
      else
         return 3,ImpactTime
      end
   end
end

function Dodge(I, Bearing)
   local __func__ = "Dodge"

   local Velocity = I:GetVelocityVector()

   local Dodges = {}
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for pindex = 0,I:GetNumberOfWarnings(mindex)-1 do
         local Projectile = I:GetMissileWarning(mindex, pindex)
         if Projectile.Valid then
            local Quadrant,ImpactTime = PredictImpactQuadrant(I, Velocity, Projectile)
            if Quadrant then
               Dodges[ImpactTime] = Quadrant
            end
         end
      end
   end

   local DodgeCount,DodgeVector = 0,Vector3.zero
   for t,Quadrant in spairs(Dodges) do
      if Debugging then Debug(I, __func__, "Quadrant = %d, ImpactTime = %f", Quadrant, t) end
      DodgeVector = DodgeVector + DodgeDirections[Quadrant]
      DodgeCount = DodgeCount + 1
      break
   end

   -- DodgeVector is local
   if DodgeCount == 0 then
      return Bearing
   else
      local NewTarget = Quaternion.Euler(0, Bearing, 0) * Vector3.forward
      NewTarget = NewTarget + DodgeVector * DodgeWeight
      NewTarget = Quaternion.Euler(0, Yaw, 0) * NewTarget
      return -I:GetTargetPositionInfoForPosition(0, NewTarget.x, 0, NewTarget.z).Azimuth
   end
end

function DodgeTest_Update(I)
   if I.AIMode == 'off' then
      GetSelfInfo(I)

      AdjustHeading(I, Dodge(I, 0))
   end
end

DodgeTest = Periodic.create(UpdateRate, DodgeTest_Update)

function Update(I)
   DodgeTest:Tick(I)
end
