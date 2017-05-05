--! rocketcontrol
--@ commonstargets commonsweapons commons periodic weapontypes quadraticintercept
function RocketControl_Update(I)
   -- Get highest-priority non-salvage target
   local Target = C:FirstTarget()
   if Target then
      -- Aim & fire all turrets/missile controllers of the appropriate slot
      for _,Weapon in pairs(C:HullWeaponControllers()) do
         if Weapon.Slot == RocketWeaponSlot and (Weapon.Type == TURRET or Weapon.Type == MISSILECONTROL) and not Weapon.PlayerControl then
            -- Calculate aim point
            local AimPoint = QuadraticIntercept(Weapon.Position, RocketSpeed*RocketSpeed, Target.AimPoint, Target.Velocity, 9999)
            -- Relative to weapon position
            AimPoint = AimPoint - Weapon.Position
            if I:AimWeaponInDirection(Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, RocketWeaponSlot) > 0 then
               I:FireWeapon(Weapon.Index, RocketWeaponSlot)
            end
         end
      end
   end
end

RocketControl = Periodic.create(UpdateRate, RocketControl_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() and ActivateWhen[I.AIMode] then
      RocketControl:Tick(I)
   end
end
