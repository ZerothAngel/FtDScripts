--@ api debug pid spinnercontrol
-- Yaw & throttle module
YawPID = PID.create(YawPIDConfig, -1.0, 1.0, UpdateRate)

PropulsionSpinners = SpinnerControl.create(Vector3.forward, UseSpinners, UseDediSpinners)

CurrentThrottle = 0

function ClassifyPropulsionSpinners(I)
   PropulsionSpinners:Classify(I)
end

-- Adjusts heading toward relative bearing
function AdjustHeading(I, Bearing)
   local __func__ = "AdjustHeading"

   -- Bearing is essentially set point - yaw, aka error
   local CV = YawPID:Control(Bearing)
   if Debugging then Debug(I, __func__, "Error = %f, CV = %f", Bearing, CV) end
   if CV > 0.0 then
      I:RequestControl(Mode, YAWRIGHT, CV)
   elseif CV < 0.0 then
      I:RequestControl(Mode, YAWLEFT, -CV)
   end
end

-- Sets throttle
function SetThrottle(I, Drive)
   I:RequestControl(Mode, MAINPROPULSION, Drive)
   PropulsionSpinners:SetSpeed(I, Drive * 30)
   CurrentThrottle = Drive
end
