--! smartmine
--@ commons periodic missiledriver smartmine
-- Simple mine main
MyMissile = SmartMine.create(Config)

GuidanceInfos = {
   {
      Controller = MyMissile,
      MinAltitude = Limits.MinAltitude,
      MaxAltitude = Limits.MaxAltitude,
      MinRange = Limits.MinRange * Limits.MinRange,
      MaxRange = Limits.MaxRange * Limits.MaxRange,
      WeaponSlot = MissileWeaponSlot,
      TargetSelector = MissileTargetSelector,
   }
}

function SelectGuidance(_, _)
   return 1
end

-- Main update loop
function MissileMain_Update(I)
   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end

MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() then
      MissileMain:Tick(I)
   end
end
