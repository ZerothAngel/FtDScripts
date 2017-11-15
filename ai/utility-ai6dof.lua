--@ commons control planarvector getvectorangle evasion avoidance6dof
-- Utility AI module (6DoF)

function MoveToWaypoint(I, Waypoint, Evasion)
   V.SetPosition(Avoidance(I, Waypoint))
   local Offset,_ = PlanarVector(C:CoM(), Waypoint)
   local Distance = Offset.magnitude
   if Evasion then
      Offset = Offset + Vector3.Cross(Offset / Distance, Vector3.up) * CalculateEvasion(Evasion)
   end
   if Distance >= OriginMaxDistance then
      V.SetHeading(GetVectorAngle(Offset))
   end
end

function UtilityAI_RunAway(I, EnemyDirection)
   if EnemyDirection then
      -- Head some arbitrary point the other way
      local Direction = (C:CoM() - EnemyDirection).normalized
      MoveToWaypoint(I, Direction * RunAwayDistance, RunAwayEvasion)
   end
end

function UtilityAI_MoveToCollect(I, Destination)
   MoveToWaypoint(I, Destination)
end

function UtilityAI_MoveToGather(I, RZInfo)
   MoveToWaypoint(I, RZInfo.Position)
end

function UtilityAI_FormationMove(I)
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
