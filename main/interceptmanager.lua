--! interceptmanager
--@ commons periodic weapontypes
-- Interceptor manager
function InterceptManager_Update(I)
   local CoM = C:CoM()
   local ToLocal = C:ToLocal()

   local ToFire = {
      Missile = {},
      Torpedo = {},
   }

   for mindex=0,I:GetNumberOfMainframes()-1 do
      for windex=0,I:GetNumberOfWarnings(mindex)-1 do
         local Missile = I:GetMissileWarning(mindex, windex)
         if Missile.Valid and Missile.Range <= InterceptRange then
            local MissilePosition = Missile.Position
            local Offset = MissilePosition - CoM
            -- Convert to local
            local LocalOffset = ToLocal * Offset
            -- Mark table accordingly by saving last missile position for quadrant
            -- for aiming purposes
            local ToFireType = MissilePosition.y > InterceptTorpedoBelow and ToFire.Missile or ToFire.Torpedo
            if LocalOffset.x < 0 then
               if LocalOffset.z < 0 then
                  ToFireType.LeftRear = Offset
               else
                  ToFireType.LeftForward = Offset
               end
            else
               if LocalOffset.z < 0 then
                  ToFireType.RightRear = Offset
               else
                  ToFireType.RightForward = Offset
               end
            end
         end
      end
   end

   local Fired = {}

   for Type,Quadrants in pairs(ToFire) do
      for Quadrant,Offset in pairs(Quadrants) do
         local WeaponSlot = InterceptWeaponSlot[Type][Quadrant]
         if WeaponSlot and not Fired[WeaponSlot] then
            -- Fire weapons
            for _,Weapon in pairs(C:WeaponControllers()) do
               if Weapon.Slot == WeaponSlot and (Weapon.Type == TURRET or Weapon.Type == MISSILECONTROL) and not Weapon.PlayerControl then
                  -- Aim and fire each weapon. Don't really care what we aim at,
                  -- but it's necessary.
                  if I:AimWeaponInDirectionOnSubConstruct(Weapon.SubConstructId, Weapon.Index, Offset.x, Offset.y, Offset.z, WeaponSlot) > 0 and Weapon.Type == MISSILECONTROL then
                     I:FireWeaponOnSubConstruct(Weapon.SubConstructId, Weapon.Index, WeaponSlot)
                  end
               end
            end

            -- Avoid firing the same weapon slot multiple times in a single frame
            Fired[WeaponSlot] = true
         end
      end
   end
end

InterceptManager = Periodic.new(UpdateRate, InterceptManager_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      InterceptManager:Tick(I)
   end
end
