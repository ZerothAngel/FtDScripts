--! rocketcontrol
--@ quadraticintercept periodic
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
            Position = Info.GlobalPosition,
         }
         table.insert(Weapons, Weapon)
      end
   end

   return Weapons
end

function GetFirstTarget(I)
   for i=0,I:GetNumberOfTargets(RocketMainframe)-1 do
      local TargetInfo = I:GetTargetInfo(RocketMainframe, i)
      if TargetInfo.Valid and TargetInfo.Protected then
         return TargetInfo
      end
   end
   return nil
end

function RocketControl_Update(I)
   -- Get highest-priority non-salvage target
   local TargetInfo = GetFirstTarget(I)
   if not TargetInfo then return end

   local Weapons = GetWeaponControllers(I)
   for _,Weapon in pairs(Weapons) do
      if Weapon.Slot == RocketWeaponSlot then
         -- Calculate aim point
         local TargetVector = (TargetInfo.AimPointPosition - Weapon.Position).normalized
         local AimPoint = QuadraticIntercept(Weapon.Position, TargetVector * RocketSpeed, TargetInfo.AimPointPosition, TargetInfo.Velocity, 9999)
         -- Relative to weapon position
         AimPoint = AimPoint - Weapon.Position
         if I:AimWeaponInDirection(Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, RocketWeaponSlot) > 0 then
            I:FireWeapon(Weapon.Index, RocketWeaponSlot)
         end
      end
   end
end

RocketControl = Periodic.create(UpdateRate, RocketControl_Update)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() and ActivateWhen[I.AIMode] then
      RocketControl:Tick(I)
   end
end
