--@ getvectorangle planarvector
--@ gettargetpositioninfo fivedof
-- Gunship AI module
PerlinOffset = 0

function GunshipAI_FirstRun(I)
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(GunshipAI_FirstRun)

-- Modifies bearing by some amount for evasive maneuvers
function Evade(I, Perp, Evasion)
   if Evasion then
      return Perp * Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * Now, PerlinOffset) - 1.0)
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
   local Offset = ToTarget * (Distance - AttackDistance) + Evade(I, Perp, Evasion)
   AdjustHeading(Bearing)
   SetPositionOffset(Offset)
   SetPitch((TargetPositionInfo.Position.y >= AirTargetAboveAltitude) and TargetPitch.Air or TargetPitch.Surface)
end

function ConditionalSetPosition(Pos)
   local Offset,_ = PlanarVector(CoM, Pos)
   if Offset.magnitude >= OriginMaxDistance then
      -- Only change heading if not in combat
      if not TargetPositionInfo then
         SetHeading(GetVectorAngle(Offset))
      end
      SetPositionOffset(Offset)
   end
end

function GunshipAI_Update(I)
   FiveDoF_Reset()

   local AIMode = I.AIMode
   if GetTargetPositionInfo(I) then
      AdjustPositionToTarget(I)
   else
      if AIMode == "combat" and ReturnToOrigin then
         ConditionalSetPosition(I.Waypoint)
      end
      SetPitch(0)
   end

   if AIMode == "patrol" or (AIMode == "fleetmove" and I.IsFlagship) then
      -- Note: I.Waypoint is the strategic waypoint. What is the actual
      -- patrol/tactical waypoint?
      ConditionalSetPosition(I.Waypoint)
   elseif AIMode == "fleetmove" then
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
