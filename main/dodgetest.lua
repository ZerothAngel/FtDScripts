--! dodgetest
--@ commons periodic yawthrottle normalizebearing quadraticsolver spairs
DodgeDirections = { -45, 45, -45, 45 }

-- Returns impact point on XZ plane at given altitude
-- Returns nil if no impact on the plane
function PredictImpact(Altitude, Projectile)
   local ProjectilePosition = Projectile.Position
   local ProjectileAltitude = ProjectilePosition.y
   local ProjectileVelocity = Projectile.Velocity
   --local Gravity = I:GetGravityForAltitude(ProjectileAltitude).y

   local a = 0 -- 0.5 * Gravity -- can't see non-missiles yet
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
      if t1 > 0 then
         ImpactTime = t1
      elseif t2 > 0 then
         ImpactTime = t2
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
function PredictImpactQuadrant(Velocity, Projectile)
   local ImpactPoint,ImpactTime = PredictImpact(C:Altitude(), Projectile)
   if not ImpactPoint then return nil end

   -- Move it to local frame of reference centered on predicted CoM
   ImpactPoint = ImpactPoint - (C:CoM() + Velocity * ImpactTime)
   ImpactPoint = C:ToLocal() * ImpactPoint

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
   local Velocity = C:Velocity()

   local Dodges = {}
   local mindex = 0
   for pindex = 0,I:GetNumberOfWarnings(mindex)-1 do
      local Projectile = I:GetMissileWarning(mindex, pindex)
      if Projectile.Valid then
         local Quadrant,ImpactTime = PredictImpactQuadrant(Velocity, Projectile)
         if Quadrant then
            Dodges[ImpactTime] = Quadrant
         end
      end
   end

   local DodgeAngle = 0
   for t,Quadrant in spairs(Dodges) do -- luacheck: ignore 512
      I:LogToHud(string.format("Quadrant = %d, ImpactTime = %f", Quadrant, t))
      DodgeAngle = DodgeDirections[Quadrant]
      break
   end

   if DodgeAngle == 0 then
      return Bearing
   else
      Bearing = NormalizeBearing(Bearing + DodgeAngle)
      return Bearing
   end
end

function DodgeTest_Update(I)
   YawThrottle_Reset()

   AdjustHeading(Dodge(I, 0))
end

DodgeTest = Periodic.create(UpdateRate, DodgeTest_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() then
      if I.AIMode == "off" then
         DodgeTest:Tick(I)

         YawThrottle_Update(I)
      end
   else
      YawThrottle_Disable(I)
   end
end
