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

function ConditionalSetPosition(Pos)
   local Offset,_ = PlanarVector(CoM, Pos)
   if Offset.magnitude >= OriginMaxDistance then
      -- Only change heading if not in combat
      if not TargetPositionInfo then
         SetHeading(GetVectorAngle(Offset))
      end
      AdjustPosition(Offset)
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
            ConditionalSetPosition(I.Waypoint)
         end
         SetPitch(0)
      end
   else
      if I.IsFlagship then
         -- Note: I.Waypoint is the strategic waypoint. What is the actual
         -- patrol/tactical waypoint?
         ConditionalSetPosition(I.Waypoint)
      else
         local Flagship = I.Fleet.Flagship
         if Flagship.Valid then
            local FlagshipRotation = Flagship.Rotation
            -- NB We don't bother with OriginMaxDistance
            -- This leads to tighter formations.
            SetPosition(Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition)
            if not TargetPositionInfo then
               SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
            end
         end
      end
   end
end
