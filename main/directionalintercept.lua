--! directionalintercept
--@ getweaponcontrollers periodic getselfinfo
function GetWeaponsForSlot(Controllers, WeaponSlot)
   local Weapons = {}

   for _,Controller in pairs(Controllers) do
      if Controller.Slot == WeaponSlot then
         table.insert(Weapons, Controller)
      end
   end

   return Weapons
end

function DirectionalIntercept_Update(I)
   local ToGlobal = Quaternion.LookRotation(I:GetConstructForwardVector(), I:GetConstructUpVector())
   local ToLocal = Quaternion.Inverse(ToGlobal)

   local ToFire = {}

   for mindex=0,I:GetNumberOfMainframes()-1 do
      for windex=0,I:GetNumberOfWarnings(mindex)-1 do
         local Missile = I:GetMissileWarning(mindex, windex)
         if Missile.Valid and Missile.Range <= InterceptRange then
            local Offset = Missile.Position - CoM
            -- Convert to local
            local LocalOffset = ToLocal * Offset
            -- Mark table accordingly by saving last missile position for octant
            -- for aiming purposes
            if LocalOffset.x < 0 then
               if LocalOffset.y < 0 then
                  if LocalOffset.z < 0 then
                     ToFire.LeftLowerRear = Offset
                  else
                     ToFire.LeftLowerForward = Offset
                  end
               else
                  if LocalOffset.z < 0 then
                     ToFire.LeftUpperRear = Offset
                  else
                     ToFire.LeftUpperForward = Offset
                  end
               end
            else
               if LocalOffset.y < 0 then
                  if LocalOffset.z < 0 then
                     ToFire.RightLowerRear = Offset
                  else
                     ToFire.RightLowerForward = Offset
                  end
               else
                  if LocalOffset.z < 0 then
                     ToFire.RightUpperRear = Offset
                  else
                     ToFire.RightUpperForward = Offset
                  end
               end
            end
         end
      end
   end

   local Controllers = nil
   local WeaponsForSlot = {}

   for Octant,Offset in pairs(ToFire) do
      local WeaponSlot = DirectionalWeaponSlot[Octant]
      if WeaponSlot then
         local Weapons = WeaponsForSlot[WeaponSlot]
         -- Lazy init
         if not Weapons then
            -- Lazy init all the things!
            if not Controllers then
               Controllers = GetWeaponControllers(I, MISSILECONTROL)
            end
            Weapons = GetWeaponsForSlot(Controllers, WeaponSlot)
            WeaponsForSlot[WeaponSlot] = Weapons
         end
         -- Fire weapons
         for _,Weapon in pairs(Weapons) do
            -- Aim and fire each weapon. Don't really care what we aim at,
            -- but it's necessary.
            if Weapon.TurretIndex then
               -- Turret mounted interceptors untested and most likely won't
               -- work
               I:AimWeaponInDirectionOnTurretOrSpinner(Weapon.TurretIndex, Weapon.Index, Offset.x, Offset.y, Offset.z, WeaponSlot)
               I:FireWeaponOnTurretOrSpinner(Weapon.TurretIndex, Weapon.Index, WeaponSlot)
            else
               I:AimWeaponInDirection(Weapon.Index, Offset.x, Offset.y, Offset.z, WeaponSlot)
               I:FireWeapon(Weapon.Index, WeaponSlot)
            end
         end
      end
   end
end

DirectionalIntercept = Periodic.create(UpdateRate, DirectionalIntercept_Update)

function Update(I)
   if not I:IsDocked() then
      GetSelfInfo(I)

      DirectionalIntercept:Tick(I)
   end
end
