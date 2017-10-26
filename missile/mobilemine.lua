--@ missiledriver smartmine
-- Mobile mine main
MyMissile = SmartMine.new(MobileMineConfig)

GuidanceInfos = {
   {
      Controller = MyMissile,
      MinAltitude = MobileMineLimits.MinAltitude,
      MaxAltitude = MobileMineLimits.MaxAltitude,
      MinRange = MobileMineLimits.MinRange * MobileMineLimits.MinRange,
      MaxRange = MobileMineLimits.MaxRange * MobileMineLimits.MaxRange,
      WeaponSlot = MobileMineWeaponSlot,
      TargetSelector = MobileMineTargetSelector,
   }
}

function SelectGuidance(_, _)
   return 1
end

-- Main update loop
function MissileMain_Update(I)
   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end
