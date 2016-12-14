--@ missiledriver unifiedmissile periodic
-- Dual profile module
MyVertical = UnifiedMissile.create(VerticalConfig)
MyHorizontal = UnifiedMissile.create(HorizontalConfig)

GuidanceInfos = {
   {
      Controller = MyVertical,
      MinAltitude = VerticalLimits.MinAltitude,
      MaxAltitude = VerticalLimits.MaxAltitude,
      MinRange = VerticalLimits.MinRange * VerticalLimits.MinRange,
      MaxRange = VerticalLimits.MaxRange * VerticalLimits.MaxRange,
      WeaponSlot = VerticalWeaponSlot,
   },
   {
      Controller = MyHorizontal,
      MinAltitude = HorizontalLimits.MinAltitude,
      MaxAltitude = HorizontalLimits.MaxAltitude,
      MinRange = HorizontalLimits.MinRange * HorizontalLimits.MinRange,
      MaxRange = HorizontalLimits.MaxRange * HorizontalLimits.MaxRange,
      WeaponSlot = HorizontalWeaponSlot,
   }
}

function IsVertical(Info)
   return math.abs(Info.LocalForwards.y) > 0.001
end

-- Returns index into GuidanceInfos
function SelectGuidance(_, BlockInfo)
   -- Really simple. Vertical launcher = vertical profile,
   -- horizontal launcher = horizontal profile
   return IsVertical(BlockInfo) and 1 or 2
end

-- Main update loop
function MissileMain_Update(I)
   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end
