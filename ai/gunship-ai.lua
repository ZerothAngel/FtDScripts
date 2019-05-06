--@ commonstargets commonsweapons commons control getvectorangle planarvector getbearingtopoint dodge3d evasion sign weapontypes clamp avoidance6dof
--@ quadraticintercept
-- Gunship AI module
DodgeAltitudeOffset = nil

-- Modifies vector by some amount for evasive maneuvers
function Evade(Evasion, Perp)
   if Evasion then
      return Perp * CalculateEvasion(Evasion)
   else
      return Vector3.zero
   end
end

function Gunship_GetWeaponSpeed(WeaponSlot)
   for _,Weapon in pairs(C:WeaponControllers()) do
      if Weapon.Slot == WeaponSlot and (Weapon.Type == CANNON or Weapon.Type == MISSILECONTROL) then
         -- Just use the first one found
         return Weapon.Speed
      end
   end
   return nil
end

function AdjustPositionToTarget(I)
   local Target = C:FirstTarget()
   local TargetPosition = Target.AimPoint
   local GroundVector = PlanarVector(C:CoM(), TargetPosition)
   local Distance = GroundVector.magnitude

   local ToTarget = GroundVector.normalized
   local Perp = Vector3.Cross(ToTarget, Vector3.up)
   local TargetAngle,TargetPitch,Evasion,LeadWeaponSlot
   if Distance > MaxDistance then
      TargetAngle = ClosingAngle
      TargetPitch = ClosingPitch
      Evasion = ClosingEvasion
      LeadWeaponSlot = ClosingLeadWeaponSlot
   elseif Distance < MinDistance then
      TargetAngle = EscapeAngle
      TargetPitch = EscapePitch
      Evasion = EscapeEvasion
      LeadWeaponSlot = EscapeLeadWeaponSlot
   else
      TargetAngle = AttackAngle
      TargetPitch = AttackPitch
      Evasion = AttackEvasion
      LeadWeaponSlot = AttackLeadWeaponSlot
   end

   if LeadWeaponSlot then
      local WeaponSpeed = Gunship_GetWeaponSpeed(LeadWeaponSlot)
      if WeaponSpeed then
         -- Predict intercept point
         TargetPosition = QuadraticIntercept(C:CoM(), WeaponSpeed*WeaponSpeed, TargetPosition, Target.Velocity, 9999)
         -- And set angle offset to 0
         TargetAngle = 0
      end
   end
   local Bearing = GetBearingToPoint(TargetPosition)
   Bearing = Bearing - Sign(Bearing, 1) * TargetAngle
   local Offset
   local DodgeX,DodgeY,DodgeZ,Dodging = Dodge()
   if Dodging then
      Offset = C:RightVector() * (DodgeX * VehicleRadius) + C:ForwardVector() * (DodgeZ * VehicleRadius)
      DodgeAltitudeOffset = DodgeY * VehicleRadius
   else
      Offset = ToTarget * (Distance - AttackDistance) + Evade(Evasion, Perp)
      DodgeAltitudeOffset = nil
   end

   V.AdjustHeading(Bearing)
   V.AdjustPosition(Avoidance(I, Offset, true))

   -- Determine pitch
   local DesiredPitch = (Target:Elevation(I) >= AirTargetAboveElevation) and TargetPitch.Air or TargetPitch.Surface
   if RelativePitch.Enabled then
      local TargetElevation = 90 - math.deg(math.atan2(Distance, Target.AimPoint.y - C:Altitude()))
      DesiredPitch = DesiredPitch + TargetElevation
      -- Constrain
      DesiredPitch = Clamp(DesiredPitch, RelativePitch.MinPitch, RelativePitch.MaxPitch)
   end
   V.SetPitch(DesiredPitch)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with MaxWanderDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      V.SetPosition(Avoidance(I, Waypoint))
      if not C:FirstTarget() then
         local Offset,_ = PlanarVector(C:CoM(), Waypoint)
         if Offset.magnitude >= MaxWanderDistance then
            V.SetHeading(GetVectorAngle(Offset))
         else
            V.SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
         end
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= MaxWanderDistance then
         V.AdjustPosition(Avoidance(I, Offset, true))
         -- Only change heading if not in combat
         if not C:FirstTarget() then
            V.SetHeading(GetVectorAngle(Offset))
         end
      end
   end
end

function GunshipAI_Reset()
   DodgeAltitudeOffset = nil
end

function GunshipAI_Update(I)
   V.Reset()

   if C:FirstTarget() then
      AdjustPositionToTarget(I)
   end

   if C:MovementMode() ~= "Fleet" then
      if not C:FirstTarget() then
         if ReturnToFormation then
            FormationMove(I)
         end
         V.SetPitch(0)
      end
   else
      FormationMove(I)
   end
end
