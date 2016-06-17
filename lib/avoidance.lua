--@ commons
-- Avoidance module
Dimensions = nil
HalfDimensions = nil
MidPoint = nil
ForwardOffset = nil

function AvoidanceFirstRun(I)
   -- TODO Should this stuff only be determined once?
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   Dimensions = MaxDim - MinDim
   HalfDimensions = Dimensions / 2
   MidPoint = MinDim + HalfDimensions -- Relative to Position and no rotation (local)

   -- Use longest (half) XZ dimension as ForwardOffset
   ForwardOffset = math.max(HalfDimensions.x, HalfDimensions.z)
   -- Convert to forward-facing vector
   ForwardOffset = Vector3(0, 0, ForwardOffset)
end

-- Modifies bearing to avoid any friendlies & terrain
function Avoidance(I, Bearing)
   local __func__ = "Avoidance"

   -- Required clearance above and below
   local PositionY = Position.y + MidPoint.y -- Not necessarily Altitude
   local UpperEdge = PositionY + HalfDimensions.y * ClearanceFactor
   local LowerEdge = PositionY - HalfDimensions.y * ClearanceFactor

   -- Look for nearby friendlies
   local FCount,FAvoid = 0,Vector3.zero
   local MinDistance = TargetInfo and FriendlyMinDistanceCombat or FriendlyMinDistanceIdle
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      -- Only consider friendlies within our altitude range
      if Friend.Valid and
         (Friend.AxisAlignedBoundingBoxMinimum.y <= UpperEdge and
          Friend.AxisAlignedBoundingBoxMaximum.y >= LowerEdge) then
         local Offset,_ = PlanarVector(CoM, Friend.CenterOfMass)
         local Distance = Offset.magnitude
         if Distance < MinDistance then
            -- Don't stand so close to me
            FCount = FCount + 1
            FAvoid = FAvoid - Offset * (MinDistance - Distance) / Distance -- i.e. (MinDistance - Distance) * Offset.normalized
         end
      end
   end
   if FCount > 0 then
      -- Normalize according to MinDistance and average out
      FAvoid = FAvoid * FriendlyAvoidanceWeight / (MinDistance * FCount)
      -- NB Vector is world vector not local
   end

   if Debugging then Debug(I, __func__, "FCount %d FAvoid %s", FCount, tostring(FAvoid)) end

   -- For now, we scan in front rather than take actual velocity into account
   local Speed = I:GetForwardsVelocityMagnitude()
   local TCount,TAvoid,TMin = 0,Vector3.zero,math.huge
   for i,t in pairs(LookAheadTimes) do
      -- Distance to look
      local Forward = ForwardOffset + Vector3.forward * t * Speed
      -- Each set of angles for each look ahead time are weighted differently
      local TimeCount,TimeAvoid = 0,Vector3.zero
      for j,a in pairs(LookAheadAngles) do
         local pos = Quaternion.Euler(0, a, 0) * Forward
         if I:GetTerrainAltitudeForLocalPosition(MidPoint + pos) >= LowerEdge then
            TimeCount = TimeCount + 1
            TimeAvoid = TimeAvoid - pos.normalized
         end
      end
      if TimeCount > 0 then
         -- NB Smaller time -> greater magnitude of average vector
         TimeAvoid = TimeAvoid / (t * TimeCount)
         -- Accumulate overall count/vector
         TCount = TCount + TimeCount
         TAvoid = TAvoid + TimeAvoid
         TMin = math.min(TMin, t)
      end
   end
   if TCount > 0 then
      -- Normalize according to smallest time
      TAvoid = TAvoid * TMin * TerrainAvoidanceWeight
      -- NB Vector is local vector
   end

   if Debugging then Debug(I, __func__, "TCount %d TAvoid %s", TCount, tostring(TAvoid)) end

   if (FCount + TCount) == 0 then
      return Bearing
   else
      -- Current target as given by Bearing
      local NewTarget = Quaternion.Euler(0, Bearing, 0) * Vector3.forward
      -- Sum of all local avoidance vectors
      NewTarget = NewTarget + TAvoid

      -- To world coordinates, and add world vectors
      NewTarget = Position + Quaternion.Euler(0, Yaw, 0) * NewTarget + FAvoid
      -- Determine new bearing
      return -I:GetTargetPositionInfoForPosition(0, NewTarget.x, 0, NewTarget.z).Azimuth
   end
end
