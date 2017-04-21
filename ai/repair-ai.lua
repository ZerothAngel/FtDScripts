--@ commons control avoidance waypointmove
-- Repair AI module (yaw-throttle)
function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(Waypoint, function (Bearing) V.AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
end

function AdjustHeadingToRepairTarget(I)
   local RepairTarget = C:FriendlyById(RepairTargetID)
   if RepairTarget and RepairTarget.Valid then
      local RepairTargetCoM = RepairTarget.CenterOfMass + RepairTarget.ForwardVector * RepairTargetOffset.z + RepairTarget.RightVector * RepairTargetOffset.x

      Control_MoveToWaypoint(I, RepairTargetCoM, RepairTarget.Velocity)
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
      AdjustHeadingToRepairTarget(I)
   else
      V.SetThrottle(0)
   end
end

function RepairAI_FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      Control_MoveToWaypoint(I, Flagship.ReferencePosition + Flagship.Rotation * I.IdealFleetPosition, Flagship.Velocity)
   else
      Control_MoveToWaypoint(I, I.Waypoint) -- Waypoint assumed to be stationary
   end
end
