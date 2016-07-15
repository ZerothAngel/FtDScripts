--@ api getselfinfo pid spinnercontrol
-- Yaw & throttle module
YawPID = PID.create(YawPIDConfig, -1.0, 1.0)

PropulsionSpinners = SpinnerControl.create(Vector3.forward, UseSpinners, UseDediSpinners)

DesiredHeading = nil
DesiredThrottle = nil
CurrentThrottle = 0

-- Normalizes a bearing to [-180, 180].
-- Input should be within [-360, 360].
function NormalizeBearing(Bearing)
   if math.abs(Bearing) > 180 then
      Bearing = Bearing - Mathf.Sign(Bearing) * 360
   end
   return Bearing
end

-- Adjusts heading toward relative bearing
function AdjustHeading(Bearing)
   DesiredHeading = NormalizeBearing(Yaw + Bearing)
end

-- Sets throttle
function SetThrottle(Drive)
   DesiredThrottle = Drive
end

-- Resets heading/throttle so they won't be touched this update
-- (unless explicitly set again)
function YawThrottle_Reset()
   DesiredHeading = nil
   DesiredThrottle = nil
end

function YawThrottle_Update(I)
   local __func__ = "YawThrottle_Update"

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
