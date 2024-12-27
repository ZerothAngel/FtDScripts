--@ commons
function CommonsWeapons_CustomName(self, I)
   if not self._CustomName then
      self._CustomName = I:GetWeaponBlockInfoOnSubConstruct(self.SubConstructId, self.Index).CustomName
   end
   return self._CustomName
end

-- The following is a pure function so just memoize the results
-- Note: If the user goes crazy with the slot selection, we'll have a very
-- large table...
Commons_SlotMask = {}

-- FIXME Quick workaround until we can deal with masks
function Commons_ConvertWeaponSlotMask(Mask)
   local Result = Commons_SlotMask[Mask]
   if Result then
      return Result
   end

   -- First (lowest) slot wins
   -- Check each bit from 1 to 9
   -- (Bit 0 is ignored since it represents "all slots")
   for i = 1, 9 do
         -- Shift the mask right by i and check if the least significant bit is 1
         if math.floor(Mask / (2 ^ i)) % 2 == 1 then
            Commons_SlotMask[Mask] = i
            return i
         end
   end
   -- If no bits are set, return 0
   Commons_SlotMask[Mask] = 0
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
