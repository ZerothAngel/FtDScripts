--! generalmissile
--@ missiledriver generalmissile periodic
-- General missile main
MyMissile = GeneralMissile.create(Config)

GuidanceInfos = {
   {
      Controller = MyMissile,
      MinAltitude = Limits.MinAltitude,
      MaxAltitude = Limits.MaxAltitude,
      MinRange = Limits.MinRange * Limits.MinRange,
      MaxRange = Limits.MaxRange * Limits.MaxRange,
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

Now = 0

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      Now = I:GetTimeSinceSpawn()
      MissileMain:Tick(I)
   end
end
