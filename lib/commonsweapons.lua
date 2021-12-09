--@ commons
function CommonsWeapons_CustomName(self, I)
   if not self._CustomName then
      self._CustomName = I:GetWeaponBlockInfoOnSubConstruct(self.SubConstructId, self.Index).CustomName
   end
   return self._CustomName
end

-- FIXME Quick workaround until we can deal with masks
function Commons_ConvertWeaponSlotMask(Mask)
   -- First (lowest) one wins
   -- Does this Lua have bitwise ops? Just assume it's a single slot for now
   if Mask == 3 then return 1 end
   if Mask == 5 then return 2 end
   if Mask == 9 then return 3 end
   if Mask == 17 then return 4 end
   if Mask == 33 then return 5 end
   return 0
end

function Commons.AddWeapon(Weapons, WeaponInfo, SubConstructId, WeaponIndex)
   local Weapon = {
      SubConstructId = SubConstructId,
      Index = WeaponIndex,
      Type = WeaponInfo.WeaponType,
      Slot = Commons_ConvertWeaponSlotMask(WeaponInfo.WeaponSlotMask),
      Position = WeaponInfo.GlobalPosition,
      FirePoint = WeaponInfo.GlobalFirePoint,
      Speed = WeaponInfo.Speed,
      PlayerControl = WeaponInfo.PlayerCurrentlyControllingIt,
      -- Lazy init methods
      CustomName = CommonsWeapons_CustomName
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
      local subids = self.I:GetAllSubConstructs()
      for sindex = 1,#subids do
         local subid = subids[sindex]
         for windex = 0,self.I:GetWeaponCountOnSubConstruct(subid)-1 do
            local Info = self.I:GetWeaponInfoOnSubConstruct(subid, windex)
            Commons.AddWeapon(Weapons, Info, subid, windex)
         end
      end
      self._WeaponControllers = Weapons
   end
   return self._WeaponControllers
end
