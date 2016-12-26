--@ commons getvectorangle planarvector getbearingtopoint evasion sign
-- Gunship AI module
-- Modifies vector by some amount for evasive maneuvers
function Evade(Evasion, Perp)
   if Evasion then
      return Perp * CalculateEvasion(Evasion)
   else
      return Vector3.zero
   end
end

function AdjustPositionToTarget()
   local TargetPosition = C:FirstTarget().Position
   local GroundVector = PlanarVector(C:CoM(), TargetPosition)
   local Distance = GroundVector.magnitude

   local ToTarget = GroundVector.normalized
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

   local Bearing = GetBearingToPoint(TargetPosition)
   Bearing = Bearing - Sign(Bearing, 1) * TargetAngle
   local Offset = ToTarget * (Distance - AttackDistance) + Evade(Evasion, Perp)
   AdjustHeading(Bearing)
   AdjustPosition(Offset)
   SetPitch((TargetPosition.y >= AirTargetAboveAltitude) and TargetPitch.Air or TargetPitch.Surface)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      SetPosition(Waypoint)
      if not C:FirstTarget() then
         local Offset,_ = PlanarVector(C:CoM(), Waypoint)
         if Offset.magnitude >= OriginMaxDistance then
            SetHeading(GetVectorAngle(Offset))
         else
            SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
         end
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         AdjustPosition(Offset)
         -- Only change heading if not in combat
         if not C:FirstTarget() then
            SetHeading(GetVectorAngle(Offset))
         end
      end
   end
end

function GunshipAI_Update(I)
   Control_Reset()

   if C:FirstTarget() then
      AdjustPositionToTarget()
   end

   if I.AIMode ~= "fleetmove" then
      if not C:FirstTarget() then
         if ReturnToOrigin then
            FormationMove(I)
         end
         SetPitch(0)
      end
   else
      FormationMove(I)
   end
end
