--@ getvectorangle planarvector evasion
-- Drop AI module
DropTargetID = nil

function GatherTargets(I)
   local TargetsByPriority = {}
   local TargetsById = {}

   local mindex = 0
   for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
      local TargetInfo = I:GetTargetInfo(mindex, tindex)
      if TargetInfo.Valid then
         local TargetId = TargetInfo.Id
         local TargetPosition = TargetInfo.Position
         local Target = {
            Id = TargetId,
            Position = TargetPosition,
            Velocity = TargetInfo.Velocity,
         }
         table.insert(TargetsByPriority, Target)
         TargetsById[TargetId] = Target
      end
   end

   return TargetsByPriority, TargetsById
end

function DropAI_Reset()
   DropTargetID = nil
end

-- Modifies vector by some amount for evasive maneuvers
function Evade(Evasion, Perp)
   if Evasion then
      return Perp * CalculateEvasion(Evasion, 0)
   else
      return Vector3.zero
   end
end

function DropAI_Main(I)
   local TargetsByPriority,TargetsById = GatherTargets(I)

   if #TargetsByPriority == 0 then return false end

   local DropTarget = nil
   if DropTargetID then
      DropTarget = TargetsById[DropTarget]
   end

   if not DropTarget then
      -- Imprint on closest
      local ClosestDistance = math.huge -- Squared
      for _,Target in pairs(TargetsByPriority) do
         local Offset = Target.Position - CoM
         local Distance = Offset.sqrMagnitude
         if Distance < ClosestDistance then
            DropTargetID = Target.Id
            DropTarget = Target
            ClosestDistance = Distance
         end
      end
   end

   local Offset = PlanarVector(CoM, DropTarget.Position)
   local Distance = Offset.magnitude
   if Distance > OriginMaxDistance then
      local Perp = Vector3.Cross(Offset / Distance, Vector3.up)
      Offset = Offset + Evade(ClosingEvasion, Perp)
      AdjustPosition(Offset)
      SetHeading(GetVectorAngle(Offset))
   else
      SetPosition(DropTarget.Position)
      SetHeading(GetVectorAngle(DropTarget.Velocity))
   end

   return true
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      SetPosition(Waypoint)
      local Offset,_ = PlanarVector(CoM, Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         SetHeading(GetVectorAngle(Offset))
      else
         SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(CoM, I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         AdjustPosition(Offset)
         SetHeading(GetVectorAngle(Offset))
      end
   end
end

function DropAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if not DropAI_Main(I) then
         DropAI_Reset()
         if ReturnToOrigin then
            FormationMove(I)
         end
      end
   else
      DropAI_Reset()
      FormationMove(I)
   end
end
