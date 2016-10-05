--@ getvectorangle planarvector evasion
--@ gettargetpositioninfo
-- Gunship AI module
-- Modifies vector by some amount for evasive maneuvers
function Evade(Evasion, Perp)
   if Evasion then
      return Perp * CalculateEvasion(Evasion, 0)
   else
      return Vector3.zero
   end
end

function AdjustPositionToTarget(I)
   local Distance = TargetPositionInfo.GroundDistance

   local ToTarget = PlanarVector(CoM, TargetPositionInfo.Position).normalized
   local Perp = Vector3.Cross(ToTarget, Vector3.up)
   local TargetAngle,TargetPitch,Evasion
   if Distance > MaxDistance then
      TargetAngle = ClosingAngle
      TargetPitch = ClosingPitch
      Evasion = ClosingEvasion
   elseif Distance < MinDistance then
      TargetAngle = EscapeAngle
      TargetPitch = EscapePitch
      Evasion = EscapeEvasion
   else
      TargetAngle = AttackAngle
      TargetPitch = AttackPitch
      Evasion = AttackEvasion
   end

   local Bearing = -TargetPositionInfo.Azimuth
   Bearing = Bearing - Mathf.Sign(Bearing) * TargetAngle
   local Offset = ToTarget * (Distance - AttackDistance) + Evade(Evasion, Perp)
   AdjustHeading(Bearing)
   AdjustPosition(Offset)
   SetPitch((TargetPositionInfo.Position.y >= AirTargetAboveAltitude) and TargetPitch.Air or TargetPitch.Surface)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      SetPosition(Waypoint)
      if not TargetPositionInfo then
         local Offset,_ = PlanarVector(CoM, Waypoint)
         if Offset.magnitude >= OriginMaxDistance then
            SetHeading(GetVectorAngle(Offset))
         else
            SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
         end
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(CoM, I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         AdjustPosition(Offset)
         -- Only change heading if not in combat
         if not TargetPositionInfo then
            SetHeading(GetVectorAngle(Offset))
         end
      end
   end
end

function GunshipAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if GetTargetPositionInfo(I) then
         AdjustPositionToTarget(I)
      else
         if ReturnToOrigin then
            FormationMove(I)
         end
         SetPitch(0)
      end
   else
      FormationMove(I)
   end
end
