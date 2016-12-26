--@ commons firstrun raysphereintersect sign
-- Dodge (common) module
LastDodgeDirection = nil
LastDodgeProjectile = nil

-- To be set by Dodge_FirstRun
SqrVehicleRadius = nil

function Dodge_FirstRun(I)
   if not VehicleRadius then
      local MaxDim = I:GetConstructMaxDimensions()
      local MinDim = I:GetConstructMinDimensions()
      local Dimensions = MaxDim - MinDim
      local HalfDimensions = Dimensions / 2

      -- Use largest dimension
      VehicleRadius = math.max(HalfDimensions.x, math.max(HalfDimensions.y, HalfDimensions.z))
      -- Fudge factor
      VehicleRadius = VehicleRadius * VehicleRadiusPadding
   end
   -- Square it
   SqrVehicleRadius = VehicleRadius * VehicleRadius
end
AddFirstRun(Dodge_FirstRun)

-- Return octant of impact point or nil if no impact
function CalculateDodge(Projectile)
   local RelativePosition = Projectile.Position - C:CoM()
   local RelativeVelocity = Projectile.Velocity - C:Velocity()
   local ImpactPoint,ImpactTime = RaySphereIntersect(RelativePosition, RelativeVelocity, SqrVehicleRadius)
   if not ImpactPoint then return nil end

   -- Move it to local frame of reference centered on predicted CoM
   -- (already relative to CoM, just rotate)
   ImpactPoint = C:ToLocal() * ImpactPoint

   -- Return signs of impact point coordinates along with impact time.
   -- Note table.pack doesn't seem to be implemented, so...
   return { Sign(ImpactPoint.x, 1), Sign(ImpactPoint.y, 1), Sign(ImpactPoint.z, 1) },ImpactTime
end

function Dodge(I)
   if MissileWarningMainframe then
      local DodgeDirection,Soonest,ProjectileId = nil,math.huge,nil
      for pindex = 0,I:GetNumberOfWarnings(MissileWarningMainframe)-1 do
         local Projectile = I:GetMissileWarning(MissileWarningMainframe, pindex)
         -- Only if valid and outside our sphere
         if Projectile.Valid and Projectile.Range > VehicleRadius then
            local Direction,ImpactTime = CalculateDodge(Projectile)
            if Direction and ImpactTime < Soonest then
               DodgeDirection = Direction
               Soonest = ImpactTime
               ProjectileId = Projectile.Id
            end
         end
      end

      if DodgeDirection then
         -- First dodge or different projectile?
         if not LastDodgeDirection or LastDodgeProjectile ~= ProjectileId then
            LastDodgeDirection = DodgeDirection
            LastDodgeProjectile = ProjectileId
         end
         return Dodge_LastDodge()
      else
         -- Nothing detected, reset
         LastDodgeDirection = nil
         LastDodgeProjectile = nil
         -- Fallthrough...
      end
   end
   return Dodge_NoDodge()
end
