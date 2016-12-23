--! rocketcontrol
--@ commons periodic quadraticintercept
function GetFirstTarget(I)
   for i=0,I:GetNumberOfTargets(RocketMainframe)-1 do
      local TargetInfo = I:GetTargetInfo(RocketMainframe, i)
      if TargetInfo.Valid and TargetInfo.Protected then
         return TargetInfo
      end
   end
   return nil
end

function RocketControl_Update(I)
   -- Get highest-priority non-salvage target
   local TargetInfo = GetFirstTarget(I)
   if not TargetInfo then return end

   for _,Weapon in pairs(C:HullWeaponControllers()) do
      if Weapon.Slot == RocketWeaponSlot and (Weapon.Type == 4 or Weapon.Type == 5) then
         -- Calculate aim point
         local TargetVector = (TargetInfo.AimPointPosition - Weapon.Position).normalized
         local AimPoint = QuadraticIntercept(Weapon.Position, TargetVector * RocketSpeed, TargetInfo.AimPointPosition, TargetInfo.Velocity, 9999)
         -- Relative to weapon position
         AimPoint = AimPoint - Weapon.Position
         if I:AimWeaponInDirection(Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, RocketWeaponSlot) > 0 then
            I:FireWeapon(Weapon.Index, RocketWeaponSlot)
         end
      end
   end
end

RocketControl = Periodic.create(UpdateRate, RocketControl_Update)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() and ActivateWhen[I.AIMode] then
      C = Commons.create(I)
      RocketControl:Tick(I)
   end
end
