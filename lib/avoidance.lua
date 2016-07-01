--@ commons getvectorangle gettargetpositioninfo
-- Avoidance module
Dimensions = nil
HalfDimensions = nil
MidPoint = nil
VerticalClearance = 0
SideClearance = 0
CheckPoints = {}

function AvoidanceFirstRun(I)
   -- TODO Should this stuff only be determined once?
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   Dimensions = MaxDim - MinDim
   HalfDimensions = Dimensions / 2
   MidPoint = MinDim + HalfDimensions -- Relative to Position and no rotation (local)

   VerticalClearance = HalfDimensions.y * ClearanceFactor
   SideClearance = HalfDimensions.x * ClearanceFactor

   -- Construct forward row of points (from which to base terrain avoidance checks)
   -- Note origin is position
   CheckPoints[1] = Vector3(0, 0, MaxDim.z)
   CheckPoints[2] = Vector3(-SideClearance, 0, MaxDim.z)
   CheckPoints[3] = Vector3(SideClearance, 0, MaxDim.z)
   if TerrainAvoidanceSubdivisions > 0 then
      local Delta = SideClearance / (TerrainAvoidanceSubdivisions+1)
      for i=1,TerrainAvoidanceSubdivisions do
         local x = i * Delta
         CheckPoints[#CheckPoints+1] = Vector3(-x, 0, MaxDim.z)
         CheckPoints[#CheckPoints+1] = Vector3(x, 0, MaxDim.z)
      end
   end
end

function GetTerrainHits(I, Angle, LowerEdge, Speed)
   local Hits = 0
   local Rotation = Quaternion.Euler(0, Angle, 0) -- NB Angle is world
   for i,Start in pairs(CheckPoints) do
      local Blocked = false
      for j,t in pairs(LookAheadTimes) do
         if Blocked then
            -- Just assume all points beyond the previous are blocked as well
            -- Also means the closer the obstacle, the greater the # of hits
            Hits = Hits + 1
         else
            local Point = Start + Vector3.forward * Speed * t
            -- TODO Someday take Y-axis velocity into account as well
            if I:GetTerrainAltitudeForPosition(Position + Rotation * Point) >= LowerEdge then
               Hits = Hits + 1
               Blocked = true
            end
         end
      end
   end
   return Hits
end

-- Modifies bearing to avoid any friendlies & terrain
function Avoidance(I, Bearing)
   local __func__ = "Avoidance"

   -- Required clearance above and below
   local PositionY = Position.y + MidPoint.y -- Not necessarily Altitude
   local UpperEdge = PositionY + VerticalClearance
   local LowerEdge = PositionY - VerticalClearance

   local Velocity = I:GetVelocityVector()
   Velocity.y = 0
   local Speed = Velocity.magnitude

   -- Look for nearby friendlies
   local FCount,FAvoid = 0,Vector3.zero
   if FriendlyAvoidanceWeight > 0 then
      local AvoidanceTime,MinDistance = 0,0
      if TargetPositionInfo then
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
   end

   if Debugging then Debug(I, __func__, "FCount %d FAvoid %s", FCount, tostring(FAvoid)) end

   local TCount,TAvoid = 0,Vector3.zero
   if TerrainAvoidanceWeight > 0 then
      local VelocityAngle = GetVectorAngle(Velocity)
      if Debugging then Debug(I, __func__, "VelocityAngle %f", VelocityAngle) end
      -- Check directly forward (w.r.t. velocity)
      local ForwardHits = GetTerrainHits(I, VelocityAngle, LowerEdge, Speed)
      if ForwardHits > 0 then
         -- Look for an exit
         local LeftHits = GetTerrainHits(I, VelocityAngle-LookAheadAngle, LowerEdge, Speed)
         local RightHits = GetTerrainHits(I, VelocityAngle+LookAheadAngle, LowerEdge, Speed)
         -- And steer left or right accordingly
         if LeftHits < RightHits then
            TAvoid = Vector3.left
         else
            -- NB Right is also favored in the case where they look the same
            TAvoid = Vector3.right
         end
         TCount = ForwardHits + LeftHits + RightHits
         TAvoid = Quaternion.Euler(0, Yaw, 0) * TAvoid * TerrainAvoidanceWeight
      end
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
