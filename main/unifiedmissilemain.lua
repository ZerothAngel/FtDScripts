--! unifiedmissile
--@ commons periodic missiledriver unifiedmissile
-- Unified missile main
MyMissile = UnifiedMissile.create(Config)

GuidanceInfos = {
   {
      Controller = MyMissile,
      MinAltitude = Limits.MinAltitude,
      MaxAltitude = Limits.MaxAltitude,
      MinRange = Limits.MinRange * Limits.MinRange,
      MaxRange = Limits.MaxRange * Limits.MaxRange,
      WeaponSlot = MissileWeaponSlot,
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
   if not I:IsDocked() then
      C = Commons.create(I)
      MissileMain:Tick(I)
   end
end
