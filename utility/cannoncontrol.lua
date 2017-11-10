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
   local Fire = false -- Because # operator only works on sequences
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
            Fire = true
            break
         end
      end
   end

   if Fire then
      -- Just assume all weapons have the same gravity
      local Gravity = -I:GetGravityForAltitude(C:Altitude())

      -- Aim & fire each turret/cannon on the hull
      for _,Weapon in pairs(C:HullWeaponControllers()) do
         local FireSlot = ToFire[Weapon.Slot]
         if FireSlot and (Weapon.Type == TURRET or Weapon.Type == CANNON) and not Weapon.PlayerControl then
            local Target,CannonAimPoint = unpack(FireSlot)
            local AimPoint = BallisticAimPoint(Weapon.Speed, CannonAimPoint - Weapon.Position, Target.RelativeVelocity, Gravity+(Target.Acceleration or Vector3.zero))
            if AimPoint then
               -- Docs say this doesn't have to be normalized, but as of
               -- 2.02 or so, it does. (Otherwise crazy recoil happens...)
               AimPoint = AimPoint.normalized
               if I:AimWeaponInDirection(Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, Weapon.Slot) > 0 and Weapon.Type == CANNON then
                  -- If this is a turret, any on-board cannons will be fired
                  -- independently below.
                  I:FireWeapon(Weapon.Index, Weapon.Slot)
               end
            end
         end
      end

      -- Now the cannons on turrets
      for _,Weapon in pairs(C:TurretWeaponControllers()) do
         local FireSlot = ToFire[Weapon.Slot]
         if FireSlot and Weapon.Type == CANNON and not Weapon.PlayerControl then 
            local Target,CannonAimPoint = unpack(FireSlot)
            local AimPoint = BallisticAimPoint(Weapon.Speed, CannonAimPoint - Weapon.Position, Target.RelativeVelocity, Gravity+(Target.Acceleration or Vector3.zero))
            if AimPoint then
               AimPoint = AimPoint.normalized
               if I:AimWeaponInDirectionOnTurretOrSpinner(Weapon.TurretIndex, Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, Weapon.Slot) > 0 then
                  I:FireWeaponOnTurretOrSpinner(Weapon.TurretIndex, Weapon.Index, Weapon.Slot)
               end
            end
         end
      end
   end
end
