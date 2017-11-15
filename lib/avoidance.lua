--@ commons avoidancevectors getbearingtopoint
-- Avoidance module (yaw version)
-- Modifies bearing to avoid any friendlies & terrain
function Avoidance(I, Bearing)
   local FCount, FAvoid, TCount, TAvoid = AvoidanceVectors(I)

   if (FCount + TCount) == 0 then
      return Bearing
   else
      -- Current target as given by Bearing
      local NewTarget = Quaternion.Euler(0, C:Yaw()+Bearing, 0) * Vector3.forward
      -- Add avoidance vectors
      NewTarget = C:CoM() + NewTarget + FAvoid + TAvoid
      -- Determine new bearing
      return GetBearingToPoint(NewTarget)
   end
end
