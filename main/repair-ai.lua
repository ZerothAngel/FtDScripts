--! repair-ai
--@ yawthrottle avoidance commons gettargetpositioninfo spairs
-- Repair AI module
FirstRun = nil
Origin = nil

ParentID = nil
RepairTargetID = nil

-- Called on first activation (not necessarily first Update)
function FirstRun(I)
   local __func__ = "FirstRun"

   FirstRun = nil

   Origin = CoM

   AvoidanceFirstRun(I)
end

function AdjustHeadingToRepairTarget(I)
   local __func__ = "AdjustHeadingToRepairTarget"

   local Drive = LoiterDrive
   local RepairTarget = I:GetFriendlyInfoById(RepairTargetID)
   if RepairTarget and RepairTarget.Valid then
      if Debugging then Debug(I, __func__, "RepairTarget %s", RepairTarget.BlueprintName) end

      local RepairTargetCoM = RepairTarget.CenterOfMass + RepairTargetOffset
      local Offset,_ = PlanarVector(CoM, RepairTargetCoM)
      local Distance = Offset.magnitude
      local Direction = Offset / Distance
      -- Not so sure about this intercept formula, since it will tend
      -- to stay parallel with parent if we don't cap InterceptTime
      local RelativeVelocity = I:GetVelocityVector() - RepairTarget.Velocity
      local RelativeSpeed = Vector3.Dot(RelativeVelocity, Direction)
      local InterceptTime = 1
      if RelativeSpeed > 0.0 then
         InterceptTime = Distance / RelativeSpeed
         InterceptTime = math.min(InterceptTime, 10)
         InterceptTime = math.max(InterceptTime, 1)
      end

      local TargetPoint = RepairTargetCoM + RepairTarget.Velocity * InterceptTime
      if Distance > ApproachMaxDistance then
         AdjustHeadingToPoint(I, TargetPoint)
         Drive = ClosingDrive
      end
   end
   return Drive
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

function Update(I)
   local AIMode = I.AIMode
   if (ActiateWhenOn and I.AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      local Drive = 0
      if GetTargetPositionInfo(I) then
         if not ParentID then
            Imprint(I)
         end
         if ParentID then
            SelectRepairTarget(I)
         end
         if RepairTargetID then
            Drive = AdjustHeadingToRepairTarget(I)
         end
      else
         ParentID = nil

         if ReturnToOrigin then
            local Target,_ = PlanarVector(CoM, Origin)
            if Target.magnitude >= OriginMaxDistance then
               AdjustHeadingToPoint(I, Origin)
               Drive = ReturnDrive
            end
         end
      end
      ClassifyPropulsionSpinners(I)
      SetThrottle(I, Drive)
   end
end
