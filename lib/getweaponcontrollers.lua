--@ commons
-- GetWeaponControllers module
-- luacheck: push ignore 131
CANNON = 0
MISSILE = 1
LASER = 2
HARPOON = 3
TURRET = 4
MISSILECONTROL = 5
FIRECONTROLCOMPUTER = 6
-- luacheck: pop

function GetWeaponControllers(_, WeaponType, Deep)
   local Weapons = {}
   for _,Weapon in pairs(C:HullWeaponControllers()) do
      if not WeaponType or Weapon.Type == WeaponType then
         table.insert(Weapons, Weapon)
      end
   end
   if Deep then
      for _,Weapon in pairs(C:TurretWeaponControllers()) do
         if not WeaponType or Weapon.Type == WeaponType then
            table.insert(Weapons, Weapon)
         end
      end
   end
   return Weapons
end
