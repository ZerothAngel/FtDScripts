--! dualprofile
--@ missiledriver unifiedmissile periodic
-- Dual profile main
MyVertical = UnifiedMissile.create(VerticalConfig)
MyHorizontal = UnifiedMissile.create(HorizontalConfig)

GuidanceInfos = {
   {
      Controller = MyVertical,
      CanTarget = function (I, TargetInfo)
         local Altitude = TargetInfo.Position.y
         return Altitude >= VerticalMinMaxAltitude[1] and Altitude <= VerticalMinMaxAltitude[2]
      end
   },
   {
      Controller = MyHorizontal,
      CanTarget = function (I, TargetInfo)
         local Altitude = TargetInfo.Position.y
         return Altitude >= HorizontalMinMaxAltitude[1] and Altitude <= HorizontalMinMaxAltitude[2]
      end
   }
}

function IsVertical(Info)
   return math.abs(Info.LocalForwards.y) > 0.001
end

-- Returns index into GuidanceInfos
function SelectGuidance(I, BlockInfo)
   -- Really simple. Vertical launcher = vertical profile,
   -- horizontal launcher = horizontal profile
   if IsVertical(BlockInfo) then
      return 1
   else
      return 2
   end
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
