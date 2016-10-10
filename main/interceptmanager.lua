--! interceptmanager
--@ periodic
-- Interceptor manager
function GetWeaponsForSlot(Controllers, WeaponSlot)
   local Weapons = {}

   for _,Controller in pairs(Controllers) do
      if Controller.Slot == WeaponSlot then
         table.insert(Weapons, Controller)
      end
   end

   return Weapons
end

TURRET = 4
MISSILECONTROL = 5

function GetWeaponControllers(I)
   local Weapons = {}

   for i = 0,I:GetWeaponCount()-1 do
      local Info = I:GetWeaponInfo(i)
      local WeaponType = Info.WeaponType
      -- Only care about turrets and missile controllers
      if WeaponType == TURRET or WeaponType == MISSILECONTROL then
         local Weapon = {
            Index = i,
            Slot = Info.WeaponSlot,
         }
         table.insert(Weapons, Weapon)
      end
   end

   return Weapons
end

function InterceptManager_Update(I)
   local CoM = I:GetConstructCenterOfMass()
   local ToGlobal = Quaternion.LookRotation(I:GetConstructForwardVector(), I:GetConstructUpVector())
   local ToLocal = Quaternion.Inverse(ToGlobal)

   local ToFire = {
      Missile = {},
      Torpedo = {},
   }

   for mindex=0,I:GetNumberOfMainframes()-1 do
      for windex=0,I:GetNumberOfWarnings(mindex)-1 do
         local Missile = I:GetMissileWarning(mindex, windex)
         if Missile.Valid and Missile.Range <= InterceptRange then
            local MissilePosition = Missile.Position
            local Offset = MissilePosition - CoM
            -- Convert to local
            local LocalOffset = ToLocal * Offset
            -- Mark table accordingly by saving last missile position for quadrant
            -- for aiming purposes
            local ToFireType = MissilePosition.y > InterceptTorpedoBelow and ToFire.Missile or ToFire.Torpedo
            if LocalOffset.x < 0 then
               if LocalOffset.z < 0 then
                  ToFireType.LeftRear = Offset
               else
                  ToFireType.LeftForward = Offset
               end
            else
               if LocalOffset.z < 0 then
                  ToFireType.RightRear = Offset
               else
                  ToFireType.RightForward = Offset
               end
            end
         end
      end
   end

   local Controllers = nil
   local WeaponsForSlot = {}
   local Fired = {}

   for Type,Quadrants in pairs(ToFire) do
      for Quadrant,Offset in pairs(Quadrants) do
         local WeaponSlot = InterceptWeaponSlot[Type][Quadrant]
         if WeaponSlot and not Fired[WeaponSlot] then
            local Weapons = WeaponsForSlot[WeaponSlot]
            -- Lazy init
            if not Weapons then
               -- Lazy init all the things!
               if not Controllers then
                  Controllers = GetWeaponControllers(I)
               end
               Weapons = GetWeaponsForSlot(Controllers, WeaponSlot)
               WeaponsForSlot[WeaponSlot] = Weapons
            end

            -- Fire weapons
            for _,Weapon in pairs(Weapons) do
               -- Aim and fire each weapon. Don't really care what we aim at,
               -- but it's necessary.
               if I:AimWeaponInDirection(Weapon.Index, Offset.x, Offset.y, Offset.z, WeaponSlot) > 0 then
                  I:FireWeapon(Weapon.Index, WeaponSlot)
               end
            end

            -- Avoid firing the same weapon slot multiple times in a single frame
            Fired[WeaponSlot] = true
         end
      end
   end
end

InterceptManager = Periodic.create(UpdateRate, InterceptManager_Update)

Now = 0

function Update(I)
   if not I:IsDocked() then
      Now = I:GetTimeSinceSpawn()
      InterceptManager:Tick(I)
   end
end
