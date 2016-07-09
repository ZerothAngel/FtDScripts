--! popupmissile
--@ missiledriver popupmissile periodic
-- Pop up missile main
MyMissile = PopUpMissile.create()

GuidanceInfos = {
   {
      Controller = MyMissile,
      CanTarget = function (I, TargetInfo) return true end
   }
}

function SelectGuidance(I, BlockInfo)
   return 1
end

-- Main update loop
function MissileMain_Update(I)
   if not I:IsDocked() then
      MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
   end
end

MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I)
   MissileMain:Tick(I)
end
