--@ commons
function Commons.AddWeapon(Weapons, WeaponInfo, TurretIndex, WeaponIndex)
   local Weapon = {
      Index = WeaponIndex,
      TurretIndex = TurretIndex,
      Type = WeaponInfo.WeaponType,
      Slot = WeaponInfo.WeaponSlot,
      Position = WeaponInfo.GlobalPosition,
      Speed = WeaponInfo.Speed,
      PlayerControl = WeaponInfo.PlayerCurrentlyControllingIt,
   }
   table.insert(Weapons, Weapon)
end

function Commons:HullWeaponControllers()
   if not self._HullWeaponControllers then
      local Weapons = {}
      for windex = 0,self.I:GetWeaponCount()-1 do
         local Info = self.I:GetWeaponInfo(windex)
         Commons.AddWeapon(Weapons, Info, nil, windex)
      end
      self._HullWeaponControllers = Weapons
   end
   return self._HullWeaponControllers
end

function Commons:TurretWeaponControllers()
   if not self._TurretWeaponControllers then
      local Weapons = {}
      for tindex = 0,self.I:GetTurretSpinnerCount()-1 do
         for windex = 0,self.I:GetWeaponCountOnTurretOrSpinner(tindex)-1 do
            local Info = self.I:GetWeaponInfoOnTurretOrSpinner(tindex, windex)
            Commons.AddWeapon(Weapons, Info, tindex, windex)
         end
      end
      self._TurretWeaponControllers = Weapons
   end
   return self._TurretWeaponControllers
end

function Commons:WeaponControllers()
   if not self._WeaponControllers then
      local Weapons = {}
      for _,Weapon in pairs(self:HullWeaponControllers()) do
         table.insert(Weapons, Weapon)
      end
      for _,Weapon in pairs(self:TurretWeaponControllers()) do
         table.insert(Weapons, Weapon)
      end
      self._WeaponControllers = Weapons
   end
   return self._WeaponControllers
end
