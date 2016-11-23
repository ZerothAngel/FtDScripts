--@ getweaponcontrollers
function CameraTrack_Update(I)
   local MainframeIndex = 0
   local TargetInfo = I:GetTargetInfo(MainframeIndex, 0)
   if TargetInfo.Valid then
      -- Note: Can't do any caching because we need global position
      local Turrets = GetWeaponControllers(I, TURRET)

      for _,Weapon in pairs(Turrets) do
         if Weapon.Slot == CameraWeaponSlot then
            local Offset = TargetInfo.Position - Weapon.Position
            I:AimWeaponInDirection(Weapon.Index, Offset.x, Offset.y, Offset.z, CameraWeaponSlot)
         end
      end
   end
end
