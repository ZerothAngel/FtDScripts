--@ commons propulsionapi normalizebearing pid sign
-- Yaw & throttle module
YawPID = PID.create(YawPIDConfig, -1, 1)

DesiredHeading = nil
DesiredThrottle = nil
CurrentThrottle = 0

YawThrottle_LastSpinnerCount = 0
YawThrottle_SpinnerInfos = {}

YawThrottle_UsesSpinners = (YawThrottleSpinnerFractions.Yaw > 0 or YawThrottleSpinnerFractions.Throttle > 0)

-- Sets heading to an absolute value, 0 is north, 90 is east
function SetHeading(Heading)
   DesiredHeading = Heading % 360
end

-- Adjusts heading toward relative bearing
function AdjustHeading(Bearing) -- luacheck: ignore 131
   SetHeading(C:Yaw() + Bearing)
end

-- Resets heading so yaw will no longer be modified
function ResetHeading()
   DesiredHeading = nil
end

-- Sets throttle. Throttle should be [-1, 1]
function SetThrottle(Throttle)
   DesiredThrottle = math.max(-1, math.min(1, Throttle))
end

-- Adjusts throttle by some delta
-- NB CurrentThrottle does not change until YawThrottle_Update is called.
function AdjustThrottle(Delta) -- luacheck: ignore 131
   SetThrottle(CurrentThrottle + Delta)
end

-- Resets throttle so drives will no longer be modified
function ResetThrottle()
   DesiredThrottle = nil
end

-- Resets heading/throttle so they will no longer be modified
-- (unless explicitly set again)
function YawThrottle_Reset() -- luacheck: ignore 131
   ResetHeading()
   ResetThrottle()
end

function YawThrottle_Classify(Index, BlockInfo, Fractions, Infos)
   -- All be spinners here
   local LocalForwards = BlockInfo.LocalRotation * Vector3.up
   if math.abs(LocalForwards.y) <= 0.001 then
      -- Horizontal
      local CoMOffset = BlockInfo.LocalPositionRelativeToCom
      local RightSign = Sign(LocalForwards.x)
      local ZSign = Sign(CoMOffset.z)
      local Info = {
         Index = Index,
         YawSign = RightSign * ZSign * Fractions.Yaw,
         ForwardSign = Sign(LocalForwards.z) * Fractions.Throttle,
      }
      if Info.YawSign ~= 0 or Info.ForwardSign ~= 0 then
         table.insert(Infos, Info)
      end
   end
end

function YawThrottle_ClassifySpinners(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= YawThrottle_LastSpinnerCount then
      YawThrottle_LastSpinnerCount = SpinnerCount
      YawThrottle_SpinnerInfos = {}

      for i = 0,SpinnerCount-1 do
         -- Only process dediblades for now
         if I:IsSpinnerDedicatedHelispinner(i) then
            local BlockInfo = I:GetSpinnerInfo(i)
            YawThrottle_Classify(i, BlockInfo, YawThrottleSpinnerFractions, YawThrottle_SpinnerInfos)
         end
      end
   end
end

-- Controls ship according to desired heading/throttle.
-- Should be called every update.
-- Default AI should be suppressed beforehand, if needed.
function YawThrottle_Update(I)
   local YawCV = DesiredHeading and YawPID:Control(NormalizeBearing(DesiredHeading - C:Yaw())) or 0
   local ForwardCV = DesiredThrottle and DesiredThrottle or 0

   if YawCV > 0 then
      I:RequestControl(Mode, YAWRIGHT, YawCV)
   elseif YawCV < 0 then
      I:RequestControl(Mode, YAWLEFT, -YawCV)
   end
   -- No request at 0

   if DesiredThrottle then
      I:RequestControl(Mode, MAINPROPULSION, DesiredThrottle)
      CurrentThrottle = DesiredThrottle
   end

   if YawThrottle_UsesSpinners then
      YawThrottle_ClassifySpinners(I)

      -- Set spinner speed
      for _,Info in pairs(YawThrottle_SpinnerInfos) do
         local YawSign,ForwardSign = Info.YawSign,Info.ForwardSign
         -- Unconditionally set yaw spinners (unfortunately won't allow non-script control)
         -- Don't touch throttle spinners if no DesiredThrottle
         if YawSign ~= 0 or (DesiredThrottle and ForwardSign ~= 0) then
            -- Sum up inputs and constrain
            local Output = YawCV * YawSign + ForwardCV * ForwardSign
            Output = math.max(-1, math.min(1, Output))
            I:SetSpinnerContinuousSpeed(Info.Index, 30 * Output)
         end
      end
   end
end

function YawThrottle_Disable(I)
   I:RequestControl(Mode, MAINPROPULSION, 0)
   CurrentThrottle = 0
   if YawThrottle_UsesSpinners then
      YawThrottle_ClassifySpinners(I)

      for _,Info in pairs(YawThrottle_SpinnerInfos) do
         I:SetSpinnerContinuousSpeed(Info.Index, 0)
      end
   end
end
