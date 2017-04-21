--@ commons control pid planarvector quadraticintercept getbearingtopoint sign
-- Waypoint move module
MTW_ThrottlePID = PID.create(WaypointMoveConfig.ThrottlePIDConfig, -1, 1)

if not WaypointMoveConfig.MinimumSpeed then WaypointMoveConfig.MinimumSpeed = 0 end

-- Scale desired speed up (or down) depending on angle between velocities
function MTW_MatchSpeed(Velocity, TargetVelocity, Faster)
   local Speed = Velocity.magnitude
   local TargetSpeed = TargetVelocity.magnitude
   -- Already calculated magnitudes...
   local VelocityDirection = Velocity / Speed
   local TargetVelocityDirection = TargetVelocity / TargetSpeed

   local CosAngle = Vector3.Dot(TargetVelocityDirection, VelocityDirection)
   local MinimumSpeed = WaypointMoveConfig.MinimumSpeed
   if CosAngle > 0 then
      local DesiredSpeed = TargetSpeed
      -- Can take CosAngle into account and scale RelativeApproachSpeed appropriately,
      -- but K.I.S.S. for now.
      DesiredSpeed = DesiredSpeed + Sign(Faster) * WaypointMoveConfig.RelativeApproachSpeed
      return math.max(MinimumSpeed, DesiredSpeed),Speed
   else
      -- Angle between velocities >= 90 degrees, go minimum speed
      return MinimumSpeed,Speed
   end
end

-- Move to a waypoint (using yaw & throttle only)
function MoveToWaypoint(Waypoint, AdjustHeading, WaypointVelocity)
   local Offset,TargetPosition = PlanarVector(C:CoM(), Waypoint)
   local Distance = Offset.magnitude

   if not WaypointVelocity then
      -- Stationary waypoint, just point and go
      if Distance >= WaypointMoveConfig.MaxDistance then
         local Bearing = GetBearingToPoint(Waypoint)
         AdjustHeading(Bearing)
         V.SetThrottle(WaypointMoveConfig.ClosingDrive)
      elseif WaypointMoveConfig.StopOnStationaryWaypoint then
         V.SetThrottle(0)
      else
         -- Set minimum speed and constantly adjust bearing
         local Bearing = GetBearingToPoint(Waypoint)
         AdjustHeading(Bearing)
         local CV = MTW_ThrottlePID:Control(WaypointMoveConfig.MinimumSpeed - C:ForwardSpeed())
         local Drive = math.max(0, math.min(1, V.GetThrottle() + CV))
         V.SetThrottle(Drive)
      end
   else
      local Direction = Offset / Distance

      local Velocity = C:Velocity()
      -- Constrain our velocity and waypoint velocity to XZ plane
      Velocity = Vector3(Velocity.x, 0, Velocity.z)
      local TargetVelocity = Vector3(WaypointVelocity.x, 0, WaypointVelocity.z)
      -- Predict intercept
      local TargetPoint = QuadraticIntercept(C:CoM(), Vector3.Dot(Velocity, Velocity), TargetPosition, TargetVelocity)

      local Bearing = GetBearingToPoint(TargetPoint)
      AdjustHeading(Bearing)

      if Distance >= WaypointMoveConfig.ApproachDistance then
         -- Go full throttle and catch up
         V.SetThrottle(WaypointMoveConfig.ClosingDrive)
      else
         -- Only go faster if waypoint is ahead of us
         local Faster = Vector3.Dot(C:ForwardVector(), Direction)
         -- Attempt to match speed
         local DesiredSpeed,Speed = MTW_MatchSpeed(Velocity, TargetVelocity, Faster)
         -- Use PID to set throttle
         local Error = DesiredSpeed - Speed
         local CV = MTW_ThrottlePID:Control(Error)
         local Drive = math.max(0, math.min(1, V.GetThrottle() + CV))
         V.SetThrottle(Drive)
      end
   end
end
