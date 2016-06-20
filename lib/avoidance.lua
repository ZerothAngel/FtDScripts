--@ commons gettarget
-- Avoidance module
Dimensions = nil
HalfDimensions = nil
MidPoint = nil

function AvoidanceFirstRun(I)
   -- TODO Should this stuff only be determined once?
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   Dimensions = MaxDim - MinDim
   HalfDimensions = Dimensions / 2
   MidPoint = MinDim + HalfDimensions -- Relative to Position and no rotation (local)
end

-- Modifies bearing to avoid any friendlies & terrain
function Avoidance(I, Bearing)
   local __func__ = "Avoidance"

   -- Required clearance above and below
   local PositionY = Position.y + MidPoint.y -- Not necessarily Altitude
   local UpperEdge = PositionY + HalfDimensions.y * ClearanceFactor
   local LowerEdge = PositionY - HalfDimensions.y * ClearanceFactor

   local Velocity = I:GetVelocityVector()
   local Speed = Velocity.magnitude

   -- Look for nearby friendlies
   local FCount,FAvoid = 0,Vector3.zero
   local AvoidanceTime,MinDistance = 0,0
   if TargetInfo then
      AvoidanceTime = FriendlyAvoidanceCombat[1]
      MinDistance = FriendlyAvoidanceCombat[2]
   else
      AvoidanceTime = FriendlyAvoidanceIdle[1]
      MinDistance = FriendlyAvoidanceIdle[2]
   end
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      -- Only consider friendlies within our altitude range
      if Friend.Valid and
         (Friend.AxisAlignedBoundingBoxMinimum.y <= UpperEdge and
          Friend.AxisAlignedBoundingBoxMaximum.y >= LowerEdge) then
         local Offset,_ = PlanarVector(CoM, Friend.CenterOfMass)
         local Distance = Offset.magnitude
         if Distance < FriendlyCheckDistance then
            local Direction = Offset / Distance -- aka Offset.normalized
            local Collision = false
            if Distance < MinDistance then
               Collision = true
            else
               -- Calculate relative speed along offset vector
               local RelativeVelocity = Velocity - Friend.Velocity
               local RelativeSpeed = Vector3.Dot(RelativeVelocity, Direction)
               if RelativeSpeed > 0.0 and Distance / RelativeSpeed < AvoidanceTime then
                  Collision = true
               end
            end
            if Collision then
               -- Collision imminent
               FCount = FCount + 1
               FAvoid = FAvoid - Direction
            end
         end
      end
   end
   if FCount > 0 then
      FAvoid = FAvoid * FriendlyAvoidanceWeight
   end

   if Debugging then Debug(I, __func__, "FCount %d FAvoid %s", FCount, tostring(FAvoid)) end

   local TCount,TAvoid = 0,Vector3.zero
   for i,a in pairs(LookAheadAngles) do
      local Direction = Quaternion.Euler(0, Yaw+a, 0) * Vector3.forward
      local Blocked = false
      for j,t in pairs(LookAheadTimes) do
         -- Distance to look
         local pos = Direction * Speed * t
         if Blocked or I:GetTerrainAltitudeForPosition(CoM + pos) >= LowerEdge then
            TCount = TCount + 1
            TAvoid = TAvoid - pos.normalized
            Blocked = true
         end
      end
   end
   if TCount > 0 then
      TAvoid = TAvoid * TerrainAvoidanceWeight
   end

   if Debugging then Debug(I, __func__, "TCount %d TAvoid %s", TCount, tostring(TAvoid)) end

   if (FCount + TCount) == 0 then
      return Bearing
   else
      -- Current target as given by Bearing
      local NewTarget = Quaternion.Euler(0, Yaw+Bearing, 0) * Vector3.forward
      -- Add avoidance vectors
      NewTarget = Position + NewTarget + FAvoid + TAvoid
      -- Determine new bearing
      return -I:GetTargetPositionInfoForPosition(0, NewTarget.x, 0, NewTarget.z).Azimuth
   end
end
