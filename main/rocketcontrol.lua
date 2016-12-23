--! rocketcontrol
--@ commons periodic quadraticintercept
function RocketControl_Update(I)
   -- Get highest-priority non-salvage target
   local Target = C:FirstTarget()
   if not Target then return end

   for _,Weapon in pairs(C:HullWeaponControllers()) do
      if Weapon.Slot == RocketWeaponSlot and (Weapon.Type == 4 or Weapon.Type == 5) then
         -- Calculate aim point
         local TargetVector = (Target.AimPoint - Weapon.Position).normalized
         local AimPoint = QuadraticIntercept(Weapon.Position, TargetVector * RocketSpeed, Target.AimPoint, Target.Velocity, 9999)
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
