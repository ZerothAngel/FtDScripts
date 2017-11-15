--@ commonsfriends commonstargets commons firstrun planarvector getvectorangle
-- Avoidance module (vectors only)
Avoidance_MidPoint = nil
Avoidance_VerticalClearance = 0
Avoidance_CheckPoints = {}

-- Used for tiebreakers
Avoidance_PreviousTAvoid = Vector3.right

function Avoidance_FirstRun(I)
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2
   Avoidance_MidPoint = MinDim + HalfDimensions -- Relative to Position and no rotation (local)

   Avoidance_VerticalClearance = HalfDimensions.y * ClearanceFactor
   local SideClearance = HalfDimensions.x * ClearanceFactor

   -- Construct forward row of points (from which to base terrain avoidance checks)
   -- Note origin is CoM
   table.insert(Avoidance_CheckPoints, 0)
   table.insert(Avoidance_CheckPoints, -SideClearance)
   table.insert(Avoidance_CheckPoints, SideClearance)
   if TerrainAvoidanceSubdivisions > 0 then
      local Delta = SideClearance / (TerrainAvoidanceSubdivisions+1)
      for i=1,TerrainAvoidanceSubdivisions do
         local x = i * Delta
         table.insert(Avoidance_CheckPoints, -x)
         table.insert(Avoidance_CheckPoints, x)
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

   for _,Offset in pairs(Avoidance_CheckPoints) do
      local Blocked = false
      for _,Distance in ipairs(Distances) do
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

function FriendlyAvoidanceVector(UpperEdge, LowerEdge, Velocity)
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
            if Distance < FriendlyCheckMaxDistance and Distance > FriendlyCheckMinDistance then
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
         -- Project onto velocity and use rejection
         local VNorm = Velocity.normalized
         local Rej = FAvoid - VNorm * Vector3.Dot(FAvoid, VNorm)
         if Rej.sqrMagnitude == 0 then
            -- However unlikely this is, default to right
            FAvoid = Vector3.Cross(Vector3.up, VNorm) * FriendlyAvoidanceWeight
         else
            FAvoid = Rej.normalized * FriendlyAvoidanceWeight
         end
      end
   end

   return FCount, FAvoid
end

function TerrainAvoidanceVector(I, LowerEdge, Velocity, Speed)
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
            TAvoid = Avoidance_PreviousTAvoid
         end
         Avoidance_PreviousTAvoid = TAvoid
         TCount = ForwardHits + LeftHits + RightHits
         TAvoid = Quaternion.Euler(0, VelocityAngle, 0) * TAvoid * TerrainAvoidanceWeight
      else
         Avoidance_PreviousTAvoid = Vector3.right
      end
   end

   return TCount, TAvoid
end

function AvoidanceVectors(I)
   -- Required clearance above and below
   local PositionY = C:Position().y + Avoidance_MidPoint.y -- Not necessarily Altitude
   local UpperEdge = PositionY + Avoidance_VerticalClearance
   local LowerEdge = PositionY - Avoidance_VerticalClearance

   -- Flatten velocity
   local Velocity = C:Velocity()
   Velocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = Velocity.magnitude

   -- Get friendly & terrain avoidance vectors
   local FCount, FAvoid = FriendlyAvoidanceVector(UpperEdge, LowerEdge, Velocity)
   local TCount, TAvoid = TerrainAvoidanceVector(I, LowerEdge, Velocity, Speed)

   return FCount, FAvoid, TCount, TAvoid
end
