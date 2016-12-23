--@ commons getweaponcontrollers
function CameraTrack_Update(I)
   local Target = C:FirstTarget()
   if Target then
      -- Note: Can't do any caching because we need global position
      local Turrets = GetWeaponControllers(I, TURRET)

      for _,Weapon in pairs(Turrets) do
         if Weapon.Slot == CameraWeaponSlot then
            local Offset = Target.Position - Weapon.Position
            I:AimWeaponInDirection(Weapon.Index, Offset.x, Offset.y, Offset.z, CameraWeaponSlot)
         end
      end
   end
end
