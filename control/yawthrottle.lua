--@ api getselfinfo normalizebearing pid spinnercontrol
-- Yaw & throttle module
YawPID = PID.create(YawPIDConfig, -1.0, 1.0)

PropulsionSpinners = SpinnerControl.create(Vector3.forward, UseSpinners, UseDediBlades)

DesiredHeading = nil
DesiredThrottle = nil
CurrentThrottle = 0

-- Sets heading to an absolute value, 0 is north, 90 is east
function SetHeading(Heading)
   DesiredHeading = Heading % 360
end

-- Adjusts heading toward relative bearing
function AdjustHeading(Bearing)
   SetHeading(Yaw + Bearing)
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
function AdjustThrottle(Delta)
   SetThrottle(CurrentThrottle + Delta)
end

-- Resets throttle so drives will no longer be modified
function ResetThrottle()
   DesiredThrottle = nil
end

-- Resets heading/throttle so they will no longer be modified
-- (unless explicitly set again)
function YawThrottle_Reset()
   ResetHeading()
   ResetThrottle()
end

-- Controls ship according to desired heading/throttle.
-- Should be called every update.
-- Default AI should be suppressed beforehand, if needed.
function YawThrottle_Update(I)
   if DesiredHeading then
      local Error = NormalizeBearing(DesiredHeading - Yaw)

      local CV = YawPID:Control(Error)
      if CV > 0.0 then
         I:RequestControl(Mode, YAWRIGHT, CV)
      elseif CV < 0.0 then
         I:RequestControl(Mode, YAWLEFT, -CV)
      end
   end

   if DesiredThrottle then
      I:RequestControl(Mode, MAINPROPULSION, DesiredThrottle)
      PropulsionSpinners:Classify(I)
      PropulsionSpinners:SetSpeed(I, DesiredThrottle * 30)
      CurrentThrottle = DesiredThrottle
   end
end

function YawThrottle_Disable(I)
   I:RequestControl(Mode, MAINPROPULSION, 0)
   PropulsionSpinners:Classify(I)
   PropulsionSpinners:SetSpeed(I, 0)
   CurrentThrottle = 0
end
