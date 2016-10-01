--@ planarvector getbearingtopoint quadraticintercept
--@ spairs pid firstrun
--@ debug gettargetpositioninfo avoidance waypointmove
-- Repair AI module
ThrottlePID = PID.create(ThrottlePIDConfig, -1, 1)

ParentID = nil
RepairTargetID = nil

-- Scale up desired speed depending on angle between velocities
function MatchSpeed(Velocity, TargetVelocity, Faster)
   local Speed = Velocity.magnitude
   local TargetSpeed = TargetVelocity.magnitude
   -- Already calculated magnitudes...
   local VelocityDirection = Velocity / Speed
   local TargetVelocityDirection = TargetVelocity / TargetSpeed

   local CosAngle = Vector3.Dot(TargetVelocityDirection, VelocityDirection)
   if CosAngle > 0 then
      local DesiredSpeed = TargetSpeed
      DesiredSpeed = DesiredSpeed + Mathf.Sign(Faster) * RelativeApproachSpeed
      return math.max(MinimumSpeed, DesiredSpeed),Speed,CosAngle
   else
      -- Angle between velocities >= 90 degrees, go minimum speed
      return MinimumSpeed,Speed,CosAngle
   end
end

function AdjustHeadingToRepairTarget(I)
   local __func__ = "AdjustHeadingToRepairTarget"

   local RepairTarget = I:GetFriendlyInfoById(RepairTargetID)
   if RepairTarget and RepairTarget.Valid then
      if Debugging then Debug(I, __func__, "RepairTarget %s", RepairTarget.BlueprintName) end

      local RepairTargetCoM = RepairTarget.CenterOfMass + RepairTarget.ForwardVector * RepairTargetOffset.z + RepairTarget.RightVector * RepairTargetOffset.x
      local Offset,TargetPosition = PlanarVector(CoM, RepairTargetCoM)
      local Distance = Offset.magnitude
      local Direction = Offset / Distance

      local Velocity = I:GetVelocityVector()
      Velocity.y = 0
      local TargetVelocity = Vector3(RepairTarget.Velocity.x, 0, RepairTarget.Velocity.z)
      local TargetPoint = QuadraticIntercept(CoM, Velocity, TargetPosition, TargetVelocity)

      local Bearing = GetBearingToPoint(TargetPoint)
      AdjustHeading(Avoidance(I, Bearing))

      if Distance > ApproachMaxDistance then
         -- Go full throttle and catch up
         return ClosingDrive
      else
         -- Only go faster if target is ahead of us
         local Faster = Vector3.Dot(I:GetConstructForwardVector(), Direction)
         -- Attempt to match speed
         local DesiredSpeed,Speed = MatchSpeed(Velocity, TargetVelocity, Faster)
         local Error = DesiredSpeed - Speed
         local CV = ThrottlePID:Control(Error)
         local Drive = CurrentThrottle + CV
         Drive = math.max(0, Drive)
         Drive = math.min(1, Drive)
         if Debugging then Debug(I, __func__, "Error = %f Drive = %f", Error, Drive) end
         return Drive
      end
   end
end

function CalculateRepairTargetWeight(I, Distance, ParentDistance, Friend)
   return Distance * DistanceWeight +
      ParentDistance * ParentDistanceWeight +
      (1.0 - Friend.HealthFraction) * DamageWeight
end

function SelectRepairTarget(I)
   local __func__ = "SelectRepairTarget"

   -- Get Parent info
   local Parent = I:GetFriendlyInfoById(ParentID)
   if Parent and not Parent.Valid then
      -- Hmm, parent gone (taken out of play?)
      -- Skip for now, select new parent next update
      RepairTargetID = nil
      -- And ensure we latch onto a new parent
      ParentID = nil
      return
   end

   local Targets = {}
   -- Parent first, adjust weight accordingly
   local ParentCoM = Parent.CenterOfMass
   local Offset,_ = PlanarVector(CoM, ParentCoM)
   Targets[Parent.Id] = CalculateRepairTargetWeight(I, Offset.magnitude, 0, Parent) * ParentBonus

   local RepairTargetMinAltitude = Altitude - RepairTargetMaxAltitudeDelta
   local RepairTargetMaxAltitude = Altitude + RepairTargetMaxAltitudeDelta

   -- Scan nearby friendlies
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      if Friend and Friend.Valid and Friend.Id ~= ParentID then
         -- Meets range and altitude requirements?
         local FriendCoM = Friend.CenterOfMass
         local FriendAlt = FriendCoM.y
         local FriendHealth = Friend.HealthFraction
         Offset,_ = PlanarVector(CoM, FriendCoM)
         local Distance = Offset.magnitude
         Offset,_ = PlanarVector(ParentCoM, FriendCoM)
         local ParentDistance = Offset.magnitude
         if Distance <= RepairTargetMaxDistance and
            ParentDistance <= RepairTargetMaxParentDistance and
            FriendAlt >= RepairTargetMinAltitude and
            FriendAlt <= RepairTargetMaxAltitude and
            FriendHealth <= RepairTargetMaxHealthFraction and
            FriendHealth >= RepairTargetMinHealthFraction then
            Targets[Friend.Id] = CalculateRepairTargetWeight(I, Distance, ParentDistance, Friend)
         end
      end
   end

   if Debugging then
      local NumTargets = 0
      -- Huh. # operator only works on sequences
      for k in pairs(Targets) do NumTargets = NumTargets+1 end
      Debug(I, __func__, "#Targets %d", NumTargets)
   end

   -- Sort
   for k,v in spairs(Targets, function(t,a,b) return t[b] < t[a] end) do
      RepairTargetID = k
      -- Only care about the first one
      break
   end
end

function Imprint(I)
   ParentID = nil
   RepairTargetID = nil
   local Closest = math.huge
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      if Friend and Friend.Valid then
         local Offset,_ = PlanarVector(CoM, Friend.CenterOfMass)
         local Distance = Offset.magnitude
         if Distance < Closest then
            Closest = Distance
            ParentID = Friend.Id
         end
      end
   end
end

function RepairAI_Reset()
   ParentID = nil
   RepairTargetID = nil
end

function RepairAI_Main(I)
   local Drive = 0
   if not ParentID then
      Imprint(I)
   end
   if ParentID then
      SelectRepairTarget(I)
   end
   if RepairTargetID then
      Drive = AdjustHeadingToRepairTarget(I)
   end
   SetThrottle(Drive)
end

function Control_MoveToWaypoint(I, Waypoint)
   MoveToWaypoint(I, Waypoint, function (Bearing) AdjustHeading(Avoidance(I, Bearing)) end)
end

function RepairAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if GetTargetPositionInfo(I) then
         RepairAI_Main(I)
      else
         if ReturnToOrigin then
            RepairAI_Reset()
            Control_MoveToWaypoint(I, I.Waypoint)
         else
            -- Basically always active, as if in combat
            RepairAI_Main(I)
         end
      end
   else
      RepairAI_Reset()

      if I.IsFlagship then
         Control_MoveToWaypoint(I, I.Waypoint)
      else
         local Flagship = I.Fleet.Flagship
         if Flagship.Valid then
            local FlagshipRotation = Flagship.Rotation
            Control_MoveToWaypoint(I, Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition)
         end
      end
   end
end
