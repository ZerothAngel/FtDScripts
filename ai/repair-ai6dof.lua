--@ commonsfriends commons control planarvector getvectorangle avoidance6dof
-- Repair AI module (6DoF)
function MoveToRepairTarget(I)
   local RepairTarget = C:FriendlyById(RepairTargetID)
   if RepairTarget and RepairTarget.Valid then
      local RepairTargetCoM = RepairTarget.CenterOfMass + RepairTarget.ForwardVector * RepairTargetOffset.z + RepairTarget.RightVector * RepairTargetOffset.x
      V.SetPosition(Avoidance(I, RepairTargetCoM))
      local Offset,_ = PlanarVector(C:CoM(), RepairTargetCoM)
      if Offset.magnitude >= OriginMaxDistance then
         V.SetHeading(GetVectorAngle(Offset))
      else
         V.SetHeading(GetVectorAngle(RepairTarget.ForwardVector))
      end
   end
end

function RepairAI_Main(I)
   if not ParentID then
      Imprint()
   end
   if ParentID then
      SelectRepairTarget()
   end
   if RepairTargetID then
      MoveToRepairTarget(I)
   end
end

function RepairAI_FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      V.SetPosition(Avoidance(I, Waypoint))
      local Offset,_ = PlanarVector(C:CoM(), Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         V.SetHeading(GetVectorAngle(Offset))
      else
         V.SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         V.AdjustPosition(Avoidance(I, Offset, true))
         V.SetHeading(GetVectorAngle(Offset))
      end
   end
end
