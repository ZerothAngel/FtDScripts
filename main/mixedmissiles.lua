--! mixedmissiles
--@ missiledriver popupmissile bottomattacktorpedo periodic
-- Mixed missiles main
MyMissile = PopUpMissile.create()
MyTorpedo = BottomAttackTorpedo.create()

GuidanceInfos = {
   {
      Controller = MyMissile,
      CanTarget = function (I, TargetInfo) return TargetInfo.Position.y >= MissileMinAltitude end
   },
   {
      Controller = MyTorpedo,
      CanTarget = function (I, TargetInfo) return TargetInfo.Position.y <= TorpedoMaxAltitude end
   }
}

function IsVertical(Info)
   -- NB If perpendicular, it's usually never exactly 0
   return math.abs(Vector3.Dot(Info.LocalForwards, Vector3.up)) > 0.001
end

-- Returns index into GuidanceInfos
function SelectGuidance(I, BlockInfo)
   -- Really simple. Vertical launcher = missile, horizontal = torpedo
   if IsVertical(BlockInfo) then
      return 1
   else
      return 2
   end
end

-- Main update loop
function MissileMain_Update(I)
   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end

MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I)
   MissileMain:Tick(I)
end
