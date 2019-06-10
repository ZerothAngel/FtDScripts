--@ commonswarnings commons firstrun raysphereintersect sign
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
function CalculateDodgeForProjectile(Projectile)
   local RelativePosition = Projectile.Position - C:CoM()
   local RelativeVelocity = Projectile.Velocity - C:Velocity()

   -- Quickly filter out anything not moving toward us
   if Vector3.Dot(RelativePosition, RelativeVelocity) >= 0 then return nil end

   local Range,Speed = RelativePosition.magnitude,RelativeVelocity.magnitude
   local ImpactPoint,ImpactTime
   -- Is it outside our sphere?
   if Range > VehicleRadius then
      -- Calculate impact point
      ImpactPoint,ImpactTime = RaySphereIntersect(RelativePosition, RelativeVelocity, SqrVehicleRadius)
      if not ImpactPoint then return nil end
      -- Normalize with imminent impacts (below)
      ImpactTime = ImpactTime + VehicleRadius / Speed
   else
      -- Just assume impact is imminent and use current position of
      -- projectile as impact point
      ImpactPoint = RelativePosition
      ImpactTime = Range / Speed
   end

   -- Move it to local frame of reference centered on predicted CoM
   -- (already relative to CoM, just rotate)
   ImpactPoint = C:ToLocal() * ImpactPoint

   return { ImpactPoint.x, ImpactPoint.y, ImpactPoint.z },ImpactTime
end

function Vanilla_CalculateDodge()
   local DodgeDirection,Soonest,ProjectileId = nil,math.huge,nil
   for _,Projectile in pairs(C:MissileWarnings()) do
      local Direction,ImpactTime = CalculateDodgeForProjectile(Projectile)
      if Direction and ImpactTime <= DodgeTimeHorizon and ImpactTime < Soonest then
         DodgeDirection = Direction
         Soonest = ImpactTime
         ProjectileId = Projectile.Id
      end
   end

   if DodgeDirection then
      -- Return signs of impact point coordinates along with impact time.
      -- Note table.pack doesn't seem to be implemented, so...
      return { Sign(DodgeDirection.x, 1), Sign(DodgeDirection.y, 1), Sign(DodgeDirection.z, 1) },ProjectileId
   else
      return nil
   end
end

function Modded_CalculateDodge()
   -- Our method returns a MissileWarningInfo, which will be Valid if we need
   -- to dodge. Position & Id will be mapped to DodgeDirection & ProjectileId.
   local Mainframe = C:MainframeIndex(CommonsWarningConfig.MissileWarningMainframe)
   local result = C.I:CalculateDodge(Mainframe, VehicleRadius, DodgeTimeHorizon)
   if result.Valid then
      local Direction = result.Position
      return { Sign(Direction.x, 1), Sign(Direction.y, 1), Sign(Direction.z, 1) },result.Id
   else
      return nil
   end
end

function CalculateDodge()
   -- Choose modded or vanilla implementation on first run
   if C.I.CalculateDodge then
      CalculateDodge = Modded_CalculateDodge
   else
      CalculateDodge = Vanilla_CalculateDodge
   end
   return CalculateDodge()
end

function Dodge()
   if DodgingEnabled then
      local DodgeDirection,ProjectileId = CalculateDodge()

      if DodgeDirection then
         -- First dodge or different projectile or different quadrant?
         if (not LastDodgeDirection or LastDodgeProjectile ~= ProjectileId or
                DodgeDirection[1] ~= LastDodgeDirection[1] or
                DodgeDirection[2] ~= LastDodgeDirection[2] or
             DodgeDirection[3] ~= LastDodgeDirection[3]) then
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
