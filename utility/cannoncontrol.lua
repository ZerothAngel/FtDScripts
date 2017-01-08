--@ ballistic weapontypes
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
      for _,Target in pairs(Targets) do
         local Range = Target.Range
         local Altitude = Target.Position.y
         if Range >= MinRange and Range <= MaxRange and Altitude >= MinAltitude and Altitude <= MaxAltitude then
            -- Add relative velocity to target table
            Target.RelativeVelocity = Target.Velocity - Velocity
            ToFire[Slot] = Target
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
         local Target = ToFire[Weapon.Slot]
         if Target and (Weapon.Type == TURRET or Weapon.Type == CANNON) and not Weapon.PlayerControl then
            local AimPoint = BallisticAimPoint(Weapon.Speed, Target.AimPoint - Weapon.Position, Target.RelativeVelocity, Gravity)
            if AimPoint and I:AimWeaponInDirection(Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, Weapon.Slot) > 0 and Weapon.Type == CANNON then
               -- If this is a turret, any on-board cannons will be fired
               -- independently below.
               I:FireWeapon(Weapon.Index, Weapon.Slot)
            end
         end
      end

      -- Now the cannons on turrets
      for _,Weapon in pairs(C:TurretWeaponControllers()) do
         local Target = ToFire[Weapon.Slot]
         if Target and Weapon.Type == CANNON and not Weapon.PlayerControl then
            local AimPoint = BallisticAimPoint(Weapon.Speed, Target.AimPoint - Weapon.Position, Target.RelativeVelocity, Gravity)
            if AimPoint and I:AimWeaponInDirectionOnTurretOrSpinner(Weapon.TurretIndex, Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, Weapon.Slot) > 0 then
               I:FireWeaponOnTurretOrSpinner(Weapon.TurretIndex, Weapon.Index, Weapon.Slot)
            end
         end
      end
   end
end
