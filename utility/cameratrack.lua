--@ commonstargets commonsweapons weapontypes
function CameraTrack_Update(I)
   local Target = C:FirstTarget()
   if Target then
      for _,Weapon in pairs(C:WeaponControllers()) do
         if Weapon.Slot == CameraWeaponSlot and Weapon.Type == TURRET then
            local Offset = Target.Position - Weapon.Position
            I:AimWeaponInDirectionOnSubConstruct(Weapon.SubConstructId, Weapon.Index, Offset.x, Offset.y, Offset.z, CameraWeaponSlot)
         end
      end
   end
end
