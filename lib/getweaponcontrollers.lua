-- GetWeaponControllers module
CANNON = 0
MISSILE = 1
LASER = 2
HARPOON = 3
TURRET = 4
MISSILECONTROL = 5
FIRECONTROLCOMPUTER = 6

function AddWeaponInfo(Weapons, WeaponInfo, WeaponType)
   if WeaponType and WeaponInfo.WeaponType ~= WeaponType then
      return
   else
      local Weapon = {
         Position = WeaponInfo.GlobalPosition,
         Slot = WeaponInfo.WeaponSlot,
      }
      table.insert(Weapons, Weapon)
   end
end

function GetWeaponControllers(I, WeaponType)
   local Weapons = {}
   for i = 0,I:GetWeaponCount()-1 do
      local Info = I:GetWeaponInfo(i)
      AddWeaponInfo(Weapons, Info, WeaponType)
   end
   for i = 0,I:GetTurretSpinnerCount()-1 do
      for j = 0,I:GetWeaponCountOnTurretOrSpinner(i)-1 do
         local Info = I:GetWeaponInfoOnTurretOrSpinner(i, j)
         AddWeaponInfo(Weapons, Info, WeaponType)
      end
   end
   return Weapons
end
