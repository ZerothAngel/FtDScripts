--@ commons planarvector getvectorangle evasion
-- Utility AI module (6DoF)

function MoveToWaypoint(Waypoint, Evasion)
   SetPosition(Waypoint)
   local Offset,_ = PlanarVector(C:CoM(), Waypoint)
   local Distance = Offset.magnitude
   if Evasion then
      Offset = Offset + Vector3.Cross(Offset / Distance, Vector3.up) * CalculateEvasion(Evasion)
   end
   if Distance >= OriginMaxDistance then
      SetHeading(GetVectorAngle(Offset))
   end
end

function UtilityAI_RunAway(_, EnemyDirection)
   if EnemyDirection then
      -- Head some arbitrary point the other way
      local Direction = (C:CoM() - EnemyDirection).normalized
      MoveToWaypoint(Direction * RunAwayDistance, RunAwayEvasion)
   end
end

function UtilityAI_MoveToCollect(_, Destination)
   MoveToWaypoint(Destination)
end

function UtilityAI_MoveToGather(_, RZInfo)
   MoveToWaypoint(RZInfo.Position)
end

function UtilityAI_FormationMove(I)
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
