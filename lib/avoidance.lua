--@ commons firstrun planarvector getvectorangle getbearingtopoint
-- Avoidance module
MidPoint = nil
VerticalClearance = 0
CheckPoints = {}

-- Used for tiebreakers
PreviousTAvoid = Vector3.right

function Avoidance_FirstRun(I)
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2
   MidPoint = MinDim + HalfDimensions -- Relative to Position and no rotation (local)

   VerticalClearance = HalfDimensions.y * ClearanceFactor
   local SideClearance = HalfDimensions.x * ClearanceFactor

   -- Construct forward row of points (from which to base terrain avoidance checks)
   -- Note origin is CoM
   table.insert(CheckPoints, 0)
   table.insert(CheckPoints, -SideClearance)
   table.insert(CheckPoints, SideClearance)
   if TerrainAvoidanceSubdivisions > 0 then
      local Delta = SideClearance / (TerrainAvoidanceSubdivisions+1)
      for i=1,TerrainAvoidanceSubdivisions do
         local x = i * Delta
         table.insert(CheckPoints, -x)
         table.insert(CheckPoints, x)
      end
   end

   if not LookAheadResolution then
      LookAheadResolution = HalfDimensions.z / 2
   end
end
AddFirstRun(Avoidance_FirstRun)

function GetTerrainHits(I, Angle, LowerEdge, Speed)
   local Hits = 0
   local Rotation = Quaternion.Euler(0, Angle, 0) -- NB Angle is world

   local MaxDistance = Speed * LookAheadTime

   -- Calculate (mid-point) distances for this velocity once
   local Distances = {}
   for d = 0,MaxDistance-1,LookAheadResolution do
      table.insert(Distances, d)
   end

   -- Make sure end point is also checked
   -- (Generally it won't be evenly divisible by LookAheadResolution)
   table.insert(Distances, MaxDistance)

   for _,Offset in pairs(CheckPoints) do
      local Blocked = false
      for _,Distance in pairs(Distances) do
         if Blocked then
            -- Just assume all points beyond the previous are blocked as well
            -- Also means the closer the obstacle, the greater the # of hits
            Hits = Hits + 1
         else
            local TestPoint = C:CoM() + Rotation * Vector3(Offset, 0, Distance)
            if I:GetTerrainAltitudeForPosition(TestPoint) >= LowerEdge then
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
   -- Required clearance above and below
   local PositionY = C:Position().y + MidPoint.y -- Not necessarily Altitude
   local UpperEdge = PositionY + VerticalClearance
   local LowerEdge = PositionY - VerticalClearance

   local Velocity = C:Velocity()
   Velocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = Velocity.magnitude

   -- Look for nearby friendlies
   local FCount,FAvoid = 0,Vector3.zero
   if FriendlyAvoidanceWeight > 0 then
      local AvoidanceTime,MinDistance
      if C:FirstTarget() then
         AvoidanceTime,MinDistance = unpack(FriendlyAvoidanceCombat)
      else
         AvoidanceTime,MinDistance = unpack(FriendlyAvoidanceIdle)
      end
      for _,Friend in pairs(C:Friendlies()) do
         -- Only consider friendlies within our altitude range
         if (Friend.AxisAlignedBoundingBoxMinimum.y <= UpperEdge and
             Friend.AxisAlignedBoundingBoxMaximum.y >= LowerEdge) then
            local Offset,_ = PlanarVector(C:CoM(), Friend.CenterOfMass)
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

   local TCount,TAvoid = 0,Vector3.zero
   if TerrainAvoidanceWeight > 0 then
      local VelocityAngle = GetVectorAngle(Velocity)
      -- Check directly forward (w.r.t. velocity)
      local ForwardHits = GetTerrainHits(I, VelocityAngle, LowerEdge, Speed)
      if ForwardHits > 0 then
         -- Look for an exit
         local LeftHits = GetTerrainHits(I, VelocityAngle-LookAheadAngle, LowerEdge, Speed)
         local RightHits = GetTerrainHits(I, VelocityAngle+LookAheadAngle, LowerEdge, Speed)
         -- And steer left or right accordingly
         if LeftHits < RightHits then
            TAvoid = Vector3.left
         elseif RightHits < LeftHits then
            TAvoid = Vector3.right
         else
            TAvoid = PreviousTAvoid
         end
         PreviousTAvoid = TAvoid
         TCount = ForwardHits + LeftHits + RightHits
         TAvoid = Quaternion.Euler(0, C:Yaw(), 0) * TAvoid * TerrainAvoidanceWeight
      else
         PreviousTAvoid = Vector3.right
      end
   end

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
