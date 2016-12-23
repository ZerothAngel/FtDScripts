--! dodgetest2
--@ yawthrottle debug commons normalizebearing raysphereintersect spairs periodic firstrun
DodgeDirections = { -45, 45, -45, 45 }

MyRadius = 0

function DodgeTest_FirstRun(I)
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2

   -- Use largest dimension
   MyRadius = math.max(HalfDimensions.x, math.max(HalfDimensions.y, HalfDimensions.z))
   -- Fudge factor
   MyRadius = MyRadius * 1.5
   -- And square it
   MyRadius = MyRadius * MyRadius
end
AddFirstRun(DodgeTest_FirstRun)

-- Return predicted impact local quadrant. Quadrants are 1-4 clockwise
-- starting with pos X/pos Z quadrant.
function PredictImpactQuadrant(I, Velocity, Projectile)
   local RelativePosition = Projectile.Position - CoM
   local RelativeVelocity = Projectile.Velocity - Velocity
   local ImpactPoint,ImpactTime = RaySphereIntersect(RelativePosition, RelativeVelocity, MyRadius)
   if not ImpactPoint then return nil end

   -- Move it to local frame of reference centered on predicted CoM
   -- (already relative to CoM, just rotate)
   ImpactPoint = Quaternion.Inverse(Quaternion.LookRotation(I:GetConstructForwardVector(), I:GetConstructUpVector())) * ImpactPoint

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
   local mindex = 0
   for pindex = 0,I:GetNumberOfWarnings(mindex)-1 do
      local Projectile = I:GetMissileWarning(mindex, pindex)
      if Projectile.Valid then
         local Quadrant,ImpactTime = PredictImpactQuadrant(I, Velocity, Projectile)
         if Quadrant then
            Dodges[ImpactTime] = Quadrant
         end
      end
   end

   local DodgeAngle = 0
   for t,Quadrant in spairs(Dodges) do -- luacheck: ignore 512
      if Debugging then Debug(I, __func__, "Quadrant = %d, ImpactTime = %f", Quadrant, t) end
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
   if I.AIMode == "off" then
      C = Commons.create(I)

      if FirstRun then FirstRun(I) end

      DodgeTest:Tick(I)

      YawThrottle_Update(I)
   end
end
