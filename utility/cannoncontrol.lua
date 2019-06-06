--@ commonstargets commonsweapons commons ballistic weapontypes
-- Cannon fire control module

-- Limits by slot
CannonLimits = {}

-- Fill out CannonLimits
for _,Config in pairs(CannonConfigs) do
   CannonLimits[Config.WeaponSlot] = Config.Limits
end

function CannonControl_Update(I)
   -- Pick highest priority target for each configured weapon slot
   local ToFire = {}
   local Targets = C:Targets()
   local Velocity = C:Velocity()
   for Slot,Limits in pairs(CannonLimits) do
      local MinRange,MaxRange = Limits.MinRange,Limits.MaxRange
      local MinAltitude,MaxAltitude = Limits.MinAltitude,Limits.MaxAltitude
      for _,Target in ipairs(Targets) do
         local Range = Target.Range
         local Altitude = Target.Position.y
         if Range >= MinRange and Range <= MaxRange and Altitude >= MinAltitude and Altitude <= MaxAltitude then
            if not Target.RelativeVelocity then
               -- Add relative velocity to target table
               Target.RelativeVelocity = Target.Velocity - Velocity
            end
            -- Calculate constrained aim point
            local AimPoint,Waterline = Target.AimPoint,Limits.ConstrainWaterline
            AimPoint = Vector3(AimPoint.x, (Waterline and math.max(Waterline, AimPoint.y) or AimPoint.y), AimPoint.z)
            -- And queue up this slot
            ToFire[Slot] = { Target, AimPoint }
            break
         end
      end
   end

   if next(ToFire) then
      -- Just assume all weapons have the same gravity
      local Gravity = -I:GetGravityForAltitude(C:Altitude())

      -- Aim & fire each turret/cannon
      for _,Weapon in pairs(C:WeaponControllers()) do
         local WeaponType = Weapon.Type
         local WeaponSlot = Weapon.Slot
         local FireSlot = ToFire[WeaponSlot]
         if FireSlot and (WeaponType == TURRET or WeaponType == CANNON) and not Weapon.PlayerControl then
            local Target,CannonAimPoint = unpack(FireSlot)
            local AimPoint = BallisticAimPoint(Weapon.Speed, CannonAimPoint - Weapon.FirePoint, Target.RelativeVelocity, Gravity+(Target.Acceleration or Vector3.zero))
            if AimPoint then
               -- Docs say this doesn't have to be normalized, but as of
               -- 2.02 or so, it does. (Otherwise crazy recoil happens...)
               AimPoint = AimPoint.normalized
               if I:AimWeaponInDirectionOnSubConstruct(Weapon.SubConstructId, Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, WeaponSlot) > 0 and WeaponType == CANNON then
                  -- If this is a turret, its cannons will presumably be fired
                  -- in some other iteration of this loop.
                  I:FireWeaponOnSubConstruct(Weapon.SubConstructId, Weapon.Index, WeaponSlot)
               end
            end
         end
      end
   end
end
