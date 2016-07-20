--! submarine
--@ getselfinfo firstrun periodic
--@ dualprofile subcontrol naval-ai
-- Submarine main
MyVertical = UnifiedMissile.create(VerticalConfig)
MyHorizontal = UnifiedMissile.create(HorizontalConfig)

GuidanceInfos = {
   {
      Controller = MyVertical,
      MinAltitude = VerticalLimits.MinAltitude,
      MaxAltitude = VerticalLimits.MaxAltitude,
      MinRange = VerticalLimits.MinRange * VerticalLimits.MinRange,
      MaxRange = VerticalLimits.MaxRange * VerticalLimits.MaxRange,
   },
   {
      Controller = MyHorizontal,
      MinAltitude = HorizontalLimits.MinAltitude,
      MaxAltitude = HorizontalLimits.MaxAltitude,
      MinRange = HorizontalLimits.MinRange * HorizontalLimits.MinRange,
      MaxRange = HorizontalLimits.MaxRange * HorizontalLimits.MaxRange,
   }
}

function IsVertical(Info)
   return math.abs(Info.LocalForwards.y) > 0.001
end

-- Returns index into GuidanceInfos
function SelectGuidance(I, BlockInfo)
   -- Really simple. Vertical launcher = vertical profile,
   -- horizontal launcher = horizontal profile
   return IsVertical(BlockInfo) and 1 or 2
end

-- Main update loop
function MissileMain_Update(I)
   if not I:IsDocked() then
      MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
   end
end

MissileMain = Periodic.create(Missile_UpdateRate, MissileMain_Update, 2)
SubControl = Periodic.create(SubControl_UpdateRate, SubControl_Control, 1)
NavalAI = Periodic.create(AI_UpdateRate, NavalAI_Update)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and AIMode ~= "off" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      SubControl:Tick(I)

      if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then

         NavalAI:Tick(I)

         -- Suppress default AI
         if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

         YawThrottle_Update(I)
      end

      SubControl_Update(I)
   end

   MissileMain:Tick(I)
end
