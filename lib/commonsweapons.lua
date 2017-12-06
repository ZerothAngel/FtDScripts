--@ commons
function Commons.AddWeapon(Weapons, WeaponInfo, SubConstructId, WeaponIndex)
   local Weapon = {
      SubConstructId = SubConstructId,
      Index = WeaponIndex,
      Type = WeaponInfo.WeaponType,
      Slot = WeaponInfo.WeaponSlot,
      Position = WeaponInfo.GlobalPosition,
      Speed = WeaponInfo.Speed,
      PlayerControl = WeaponInfo.PlayerCurrentlyControllingIt,
   }
   table.insert(Weapons, Weapon)
end

function Commons:WeaponControllers()
   if not self._WeaponControllers then
      local Weapons = {}
      for windex = 0,self.I:GetWeaponCount()-1 do
         local Info = self.I:GetWeaponInfo(windex)
         -- Note that main hull is designated as subconstruct ID 0 (apparently)
         -- Take advantage of this so we have an easier time aiming & firing.
         Commons.AddWeapon(Weapons, Info, 0, windex)
      end
      for _,subid in pairs(self.I:GetAllSubConstructs()) do
         for windex = 0,self.I:GetWeaponCountOnSubConstruct(subid)-1 do
            local Info = self.I:GetWeaponInfoOnSubConstruct(subid, windex)
            Commons.AddWeapon(Weapons, Info, subid, windex)
         end
      end
      self._WeaponControllers = Weapons
   end
   return self._WeaponControllers
end
