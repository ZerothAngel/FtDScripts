--@ planarvector getbearingtopoint evasion
--@ debug gettargetpositioninfo avoidance
-- Naval AI module
Attacking = true
LastAttackTime = 0

-- Modifies bearing by some amount for evasive maneuvers
function Evade(Evasion, Bearing)
   if AirRaidEvasion and TargetPositionInfo.Position.y >= AirRaidAboveAltitude then
      Evasion = AirRaidEvasion
   end

   return CalculateEvasion(Evasion, Bearing)
end

-- Adjusts heading according to configured behaviors
function AdjustHeadingToTarget(I)
   local __func__ = "AdjustHeadingToTarget"

   local Distance = TargetPositionInfo.GroundDistance
   local Bearing = -TargetPositionInfo.Azimuth
   if Debugging then Debug(I, __func__, "Distance %f Bearing %f", Distance, Bearing) end

   local State,TargetAngle,Drive,Evasion = "escape",EscapeAngle,EscapeDrive,EscapeEvasion
   if Distance > MaxDistance then
      State = "closing"
      TargetAngle = ClosingAngle
      Drive = ClosingDrive
      Evasion = ClosingEvasion

      Attacking = true
   elseif Distance > MinDistance then
      if not AttackRuns or Attacking or (LastAttackTime + ForceAttackTime) <= Now then
         State = "attack"
         TargetAngle = AttackAngle
         Drive = AttackDrive
         Evasion = AttackEvasion

         Attacking = true
         LastAttackTime = Now
      end
   elseif Distance <= MinDistance then
      Attacking = false
   end

   Bearing = Bearing - Mathf.Sign(Bearing) * TargetAngle
   Bearing = Evade(Evasion, Bearing)
   if Bearing > 180 then Bearing = Bearing - 360 end

   if Debugging then Debug(I, __func__, "State %s Drive %f Bearing %f", State, Drive, Bearing) end

   AdjustHeading(Avoidance(I, Bearing))

   return Drive
end

function NavalAI_Update(I)
   Control_Reset()

   local Drive = nil
   if GetTargetPositionInfo(I) then
      Drive = AdjustHeadingToTarget(I)
   elseif ReturnToOrigin then
      local Target,_ = PlanarVector(CoM, I.Waypoint)
      local Distance = Target.magnitude
      if Distance >= OriginMaxDistance then
         local Bearing = GetBearingToPoint(I.Waypoint)
         AdjustHeading(Avoidance(I, Bearing))
         if Vector3.Dot(Target, I:GetConstructForwardVector()) > 0 or Distance >= OriginMaxDistance then
            Drive = math.max(0, math.min(1, ReturnDriveGain * Distance))
         end
      end
      if not Drive then Drive = 0 end
   else
      -- Just continue along with avoidance active
      AdjustHeading(Avoidance(I, 0))
   end
   if Drive then
      SetThrottle(Drive)
   end
end
