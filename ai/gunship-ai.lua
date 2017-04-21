--@ commons control getvectorangle planarvector getbearingtopoint dodge3d evasion sign weapontypes
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
   -- Only consider hull mounted cannons or missile controllers
   for _,Weapon in pairs(C:HullWeaponControllers()) do
      if Weapon.Slot == WeaponSlot and (Weapon.Type == CANNON or Weapon.Type == MISSILECONTROL) then
         -- Just use the first one found
         return Weapon.Speed
      end
   end
   return nil
end

function AdjustPositionToTarget(I)
   local TargetPosition = C:FirstTarget().Position
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
         TargetPosition = QuadraticIntercept(C:CoM(), WeaponSpeed*WeaponSpeed, TargetPosition, C:FirstTarget().Velocity, 9999)
         -- And set angle offset to 0
         TargetAngle = 0
      end
   end
   local Bearing = GetBearingToPoint(TargetPosition)
   Bearing = Bearing - Sign(Bearing, 1) * TargetAngle
   local Offset
   local DodgeX,DodgeY,DodgeZ,Dodging = Dodge(I)
   if Dodging then
      Offset = C:RightVector() * (DodgeX * VehicleRadius) + C:ForwardVector() * (DodgeZ * VehicleRadius)
      DodgeAltitudeOffset = DodgeY * VehicleRadius
   else
      Offset = ToTarget * (Distance - AttackDistance) + Evade(Evasion, Perp)
      DodgeAltitudeOffset = nil
   end

   V.AdjustHeading(Bearing)
   V.AdjustPosition(Offset)
   V.SetPitch((TargetPosition.y >= AirTargetAboveAltitude) and TargetPitch.Air or TargetPitch.Surface)
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      V.SetPosition(Waypoint)
      if not C:FirstTarget() then
         local Offset,_ = PlanarVector(C:CoM(), Waypoint)
         if Offset.magnitude >= OriginMaxDistance then
            V.SetHeading(GetVectorAngle(Offset))
         else
            V.SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
         end
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         V.AdjustPosition(Offset)
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

   if I.AIMode ~= "fleetmove" then
      if not C:FirstTarget() then
         if ReturnToOrigin then
            FormationMove(I)
         end
         V.SetPitch(0)
      end
   else
      FormationMove(I)
   end
end
