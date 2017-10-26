--@ commonstargets commons control planarvector getbearingtopoint sign evasion normalizebearing pid
--@ dodgeyaw avoidance waypointmove
-- Naval AI module
Attacking = false
LastAttackTime = nil

DodgeAltitudeOffset = nil -- luacheck: ignore 131

AttackPID = PID.create(AttackPIDConfig, -1, 1)

-- Modifies bearing by some amount for evasive maneuvers
function Evade(Evasion)
   if AirRaidEvasion and C:FirstTarget():Elevation(C.I) >= AirRaidAboveElevation then
      Evasion = AirRaidEvasion
   end

   return CalculateEvasion(Evasion)
end

-- Adjusts heading according to configured behaviors
function AdjustHeadingToTarget(I)
   local TargetPosition = C:FirstTarget().Position
   local Distance = PlanarVector(C:CoM(), TargetPosition).magnitude

   local TargetAngle,Drive,Evasion = EscapeAngle,EscapeDrive,EscapeEvasion
   local ScaledDrive = false
   if AttackRuns then
      -- Attack run behavior
      if not LastAttackTime then
         -- Initialize LastAttackTime if needed
         LastAttackTime = C:Now()
      end

      if Distance > MaxDistance then
         -- Unconditionally closing
         TargetAngle = ClosingAngle
         Drive = ClosingDrive
         Evasion = ClosingEvasion

         -- Begin normal attack run
         Attacking = true
         LastAttackTime = C:Now()
      else
         if Attacking then
            TargetAngle = AttackAngle
            Drive = AttackDrive
            Evasion = AttackEvasion
         end
         -- Otherwise escaping
      end

      -- Determine next state
      if Attacking and Distance <= MinDistance and (LastAttackTime + MinAttackTime) < C:Now() then
         -- End attack run on reaching MinDistance
         -- ...as long as MinAttackTime expired
         Attacking = false
      elseif not Attacking and (LastAttackTime + ForceAttackTime) < C:Now() then
         -- Forced attack run
         Attacking = true
         LastAttackTime = C:Now()
      end
   else
      -- Normal broadsiding behavior
      if Distance > MaxDistance then
         -- Closing
         TargetAngle = ClosingAngle
         Drive = ClosingDrive
         Evasion = ClosingEvasion
      elseif Distance > MinDistance then
         -- Attacking
         TargetAngle = AttackAngle
         Drive = AttackDrive
         Evasion = AttackEvasion
         -- Attempt to keep at a certain distance by either flipping
         -- AttackAngle or reversing.
         if AttackDistance then
            local Delta = AttackDistance - Distance
            if AttackReverse then
               Drive = AttackPID:Control(Delta) * -AttackDrive
               ScaledDrive = true
            else
               local BroadsideAngle = 90 - AttackAngle
               TargetAngle = 90 + AttackPID:Control(Delta) * BroadsideAngle
            end
         end
      end
      -- Otherwise escaping
   end

   local Bearing
   local DodgeAngle,DodgeY,Dodging = Dodge()
   if Dodging then
      DodgeAltitudeOffset = DodgeY * VehicleRadius
      if ScaledDrive then
         -- Because of the PID, Drive may be (close to) 0.
         -- So it's better to force it to max in the current direction.
         Drive = Sign(C:ForwardSpeed(), 1)
      end
      Bearing = DodgeAngle * Sign(Drive, 1)
   else
      Bearing = GetBearingToPoint(TargetPosition)
      Bearing = Bearing - (PreferredBroadside or Sign(Bearing, 1)) * TargetAngle
      Bearing = Bearing + Evade(Evasion, Bearing)
      Bearing = NormalizeBearing(Bearing)
      DodgeAltitudeOffset = nil
   end

   V.AdjustHeading(Avoidance(I, Bearing))
   V.SetThrottle(Drive)
end

function NavalAI_Reset()
   Attacking = false
   LastAttackTime = nil
   DodgeAltitudeOffset = nil
end

function Control_MoveToWaypoint(I, Waypoint, WaypointVelocity)
   MoveToWaypoint(Waypoint, function (Bearing) V.AdjustHeading(Avoidance(I, Bearing)) end, WaypointVelocity)
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
   V.Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if C:FirstTarget() then
         AdjustHeadingToTarget(I)
      elseif ReturnToOrigin then
         NavalAI_Reset()
         FormationMove(I)
      else
         NavalAI_Reset()
         -- Just continue along with avoidance active
         V.AdjustHeading(Avoidance(I, 0))
      end
   else
      NavalAI_Reset()
      FormationMove(I)
   end
end
