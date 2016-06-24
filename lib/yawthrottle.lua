--@ commons pid
-- Yaw & throttle module
YawPID = PID.create(YawPIDValues[1], YawPIDValues[2], YawPIDValues[3], -1.0, 1.0)

PropulsionSpinners = {}

-- Gather spinners aligned along the Z-axis
function ClassifyPropulsionSpinners(I)
   local __func__ = "ClassifyPropulsionSpinners"

   PropulsionSpinners = {}
   if UseSpinners or UseDediSpinners then
      for i = 0,I:GetSpinnerCount()-1 do
         if (UseDediSpinners and I:IsSpinnerDedicatedHelispinner(i)) or UseSpinners then
            local Info = I:GetSpinnerInfo(i)
            local ForwardFraction = Vector3.Dot(Info.LocalRotation * Vector3.up,
                                                Vector3.forward)
            if math.abs(ForwardFraction) > 0.001 then -- Sometimes there's -0
               if Debugging then Debug(I, __func__, "Index %d ForwardFraction %f", i, ForwardFraction) end
               local Spinner = {
                  Index = i,
                  ForwardFraction = ForwardFraction
               }
               PropulsionSpinners[#PropulsionSpinners+1] = Spinner
            end
         end
      end
   end
end

-- Adjusts heading toward relative bearing
function AdjustHeading(I, Bearing)
   local __func__ = "AdjustHeading"

   Bearing = Avoidance(I, Bearing)
   -- Bearing is essentially set point - yaw, aka error
   local CV = YawPID:Control(Bearing)
   if Debugging then Debug(I, __func__, "Error = %f, CV = %f", Bearing, CV) end
   if CV > 0.0 then
      I:RequestControl(Mode, YAWRIGHT, CV)
   elseif CV < 0.0 then
      I:RequestControl(Mode, YAWLEFT, -CV)
   end
end

-- Adjust heading toward a given world point
function AdjustHeadingToPoint(I, Point)
   AdjustHeading(I, -I:GetTargetPositionInfoForPosition(0, Point.x, 0, Point.z).Azimuth)
end

-- Sets throttle
function SetThrottle(I, Drive)
   I:RequestControl(Mode, MAINPROPULSION, Drive)
   for i,Spinner in pairs(PropulsionSpinners) do
      I:SetSpinnerContinuousSpeed(Spinner.Index, Drive * 30 / Spinner.ForwardFraction)
   end
end
