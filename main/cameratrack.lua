--! cameratrack
--@ gettargetinfo getweaponcontrollers periodic
function CameraTrack_Update(I)
   if GetTargetInfo(I) then
      local Turrets = GetWeaponControllers(I, TURRET)

      for _,Weapon in pairs(Turrets) do
         if Weapon.Slot == CameraWeaponSlot then
            local Offset = TargetInfo.Position - Weapon.Position
            I:AimWeaponInDirection(Weapon.Index, Offset.x, Offset.y, Offset.z, CameraWeaponSlot)
         end
      end
   end
end

CameraTrack = Periodic.create(UpdateRate, CameraTrack_Update)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      CameraTrack:Tick(I)
   end
end
