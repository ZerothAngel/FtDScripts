-- Control mode. Set to WATER, LAND, or AIR.
Mode = AIR

-- Re-scale decel condition
if CruiseMissileConfig.DetonationDecel then
   CruiseMissileConfig.DetonationDecel = CruiseMissileConfig.DetonationDecel * AI_UpdateRate / 40
end
