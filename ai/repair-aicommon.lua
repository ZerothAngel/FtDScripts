--@ commonsfriends commonstargets commons control planarvector
-- Repair AI module (common)
ParentID = nil
RepairTargetID = nil

function CalculateRepairTargetWeight(Distance, ParentDistance, Friend)
   return Distance * DistanceWeight +
      ParentDistance * ParentDistanceWeight +
      (1.0 - Friend.HealthFraction) * DamageWeight
end

function SelectRepairTarget()
   -- Call this here to pre-populate the friendly-by-ID cache
   C:Friendlies()

   -- Get Parent info
   local Parent = C:FriendlyById(ParentID)
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
   local Offset,_ = PlanarVector(C:CoM(), ParentCoM)
   table.insert(Targets, { Parent.Id, CalculateRepairTargetWeight(Offset.magnitude, 0, Parent) * ParentBonus })

   local RepairTargetMinAltitude = C:Altitude() - RepairTargetMaxAltitudeDelta
   local RepairTargetMaxAltitude = C:Altitude() + RepairTargetMaxAltitudeDelta

   -- Scan nearby friendlies
   for _,Friend in pairs(C:Friendlies()) do
      if Friend.Id ~= ParentID then
         -- Meets range and altitude requirements?
         local FriendCoM = Friend.CenterOfMass
         local FriendAlt = FriendCoM.y
         local FriendHealth = Friend.HealthFraction
         Offset,_ = PlanarVector(C:CoM(), FriendCoM)
         local Distance = Offset.magnitude
         Offset,_ = PlanarVector(ParentCoM, FriendCoM)
         local ParentDistance = Offset.magnitude
         if Distance <= RepairTargetMaxDistance and
            ParentDistance <= RepairTargetMaxParentDistance and
            FriendAlt >= RepairTargetMinAltitude and
            FriendAlt <= RepairTargetMaxAltitude and
            FriendHealth <= RepairTargetMaxHealthFraction and
         FriendHealth >= RepairTargetMinHealthFraction then
            table.insert(Targets, { Friend.Id, CalculateRepairTargetWeight(Distance, ParentDistance, Friend) })
         end
      end
   end

   -- Sort in descending order
   table.sort(Targets, function (a,b) return b[2] < a[2] end)
   -- Only care about the first one
   RepairTargetID = Targets[1][1]
end

function Imprint()
   ParentID = nil
   RepairTargetID = nil
   local Closest = math.huge
   for _,Friend in pairs(C:Friendlies()) do
      local Offset,_ = PlanarVector(C:CoM(), Friend.CenterOfMass)
      local Distance = Offset.sqrMagnitude
      if Distance < Closest then
         Closest = Distance
         ParentID = Friend.Id
      end
   end
end

function RepairAI_Reset()
   ParentID = nil
   RepairTargetID = nil
end

function RepairAI_Update(I)
   V.Reset()

   if C:MovementMode() ~= "Fleet" then
      if C:FirstTarget() then
         RepairAI_Main(I)
      else
         if ReturnToFormation then
            RepairAI_Reset()
            RepairAI_FormationMove(I)
         else
            -- Basically always active, as if in combat
            RepairAI_Main(I)
         end
      end
   else
      RepairAI_Reset()
      RepairAI_FormationMove(I)
   end
end
