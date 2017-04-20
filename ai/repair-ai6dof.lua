--@ commons planarvector getvectorangle
-- Repair AI module (6DoF)
function MoveToRepairTarget()
   local RepairTarget = C:FriendlyById(RepairTargetID)
   if RepairTarget and RepairTarget.Valid then
      local RepairTargetCoM = RepairTarget.CenterOfMass + RepairTarget.ForwardVector * RepairTargetOffset.z + RepairTarget.RightVector * RepairTargetOffset.x
      SetPosition(RepairTargetCoM)
      local Offset,_ = PlanarVector(C:CoM(), RepairTargetCoM)
      if Offset.magnitude >= OriginMaxDistance then
         SetHeading(GetVectorAngle(Offset))
      else
         SetHeading(GetVectorAngle(RepairTarget.ForwardVector))
      end
   end
end

function RepairAI_Main(_)
   if not ParentID then
      Imprint()
   end
   if ParentID then
      SelectRepairTarget()
   end
   if RepairTargetID then
      MoveToRepairTarget()
   end
end

function RepairAI_FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      SetPosition(Waypoint)
      local Offset,_ = PlanarVector(C:CoM(), Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         SetHeading(GetVectorAngle(Offset))
      else
         SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         AdjustPosition(Offset)
         SetHeading(GetVectorAngle(Offset))
      end
   end
end
