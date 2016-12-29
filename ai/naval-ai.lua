--@ commons planarvector getbearingtopoint sign evasion normalizebearing
--@ dodgeyaw avoidance waypointmove
-- Naval AI module
Attacking = true
LastAttackTime = 0

DodgeAltitudeOffset = nil -- luacheck: ignore 131

-- Modifies bearing by some amount for evasive maneuvers
function Evade(Evasion)
   if AirRaidEvasion and C:FirstTarget().Position.y >= AirRaidAboveAltitude then
      Evasion = AirRaidEvasion
   end

   return CalculateEvasion(Evasion)
end

-- Adjusts heading according to configured behaviors
function AdjustHeadingToTarget(I)
   local TargetPosition = C:FirstTarget().Position
   local Distance = PlanarVector(C:CoM(), TargetPosition).magnitude

   local TargetAngle,Drive,Evasion = EscapeAngle,EscapeDrive,EscapeEvasion
   if Distance > MaxDistance then
      TargetAngle = ClosingAngle
      Drive = ClosingDrive
      Evasion = ClosingEvasion

      Attacking = true
   elseif Distance > MinDistance then
      if not AttackRuns or Attacking or (LastAttackTime + ForceAttackTime) <= C:Now() then
         TargetAngle = AttackAngle
         Drive = AttackDrive
         Evasion = AttackEvasion

         Attacking = true
         LastAttackTime = C:Now()
      end
   elseif Distance <= MinDistance then
      Attacking = false
   end

   local Bearing
   local DodgeAngle,DodgeY,Dodging = Dodge(I)
   if Dodging then
      Bearing = DodgeAngle
      DodgeAltitudeOffset = DodgeY * VehicleRadius
   else
      Bearing = GetBearingToPoint(TargetPosition)
      Bearing = Bearing - Sign(Bearing, 1) * TargetAngle
      Bearing = Bearing + Evade(Evasion, Bearing)
      Bearing = NormalizeBearing(Bearing)
      DodgeAltitudeOffset = nil
   end

   AdjustHeading(Avoidance(I, Bearing))
   SetThrottle(Drive)
end

function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(I, Waypoint, function (Bearing) AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      Control_MoveToWaypoint(I, Flagship.ReferencePosition + Flagship.Rotation * I.IdealFleetPosition, Flagship.Velocity)
   else
      Control_MoveToWaypoint(I, I.Waypoint) -- Waypoint assumed to be stationary
   end
end

function NavalAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if C:FirstTarget() then
         AdjustHeadingToTarget(I)
      elseif ReturnToOrigin then
         FormationMove(I)
      else
         -- Just continue along with avoidance active
         AdjustHeading(Avoidance(I, 0))
      end
   else
      FormationMove(I)
   end
end
