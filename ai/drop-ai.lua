--@ commonstargets commons control getvectorangle planarvector dodge3d evasion avoidance6dof
-- Drop AI module
DodgeAltitudeOffset = nil
DropTargetID = nil

-- Global that downstream modules can check
DropAI_Closing = false

function DropAI_GatherTargets()
   local TargetsByPriority = {}
   local TargetsById = {}

   for _,Target in ipairs(C:Targets()) do
      table.insert(TargetsByPriority, Target)
      TargetsById[Target.Id] = Target
   end

   return TargetsByPriority, TargetsById
end

function DropAI_Reset()
   DropTargetID = nil
   DodgeAltitudeOffset = nil
end

-- Modifies vector by some amount for evasive maneuvers
function Evade(Evasion, Perp)
   if Evasion then
      return Perp * CalculateEvasion(Evasion)
   else
      return Vector3.zero
   end
end

function DropAI_Main(I)
   local TargetsByPriority,TargetsById = DropAI_GatherTargets()

   if #TargetsByPriority == 0 then return false end

   local DropTarget = nil
   if DropTargetID then
      DropTarget = TargetsById[DropTargetID]
   end

   if not DropTarget then
      -- Imprint on closest
      local ClosestDistance = math.huge -- Squared
      for _,Target in ipairs(TargetsByPriority) do
         local Offset,_ = PlanarVector(C:CoM(), Target.Position)
         local Distance = Offset.sqrMagnitude
         if Distance < ClosestDistance then
            DropTargetID = Target.Id
            DropTarget = Target
            ClosestDistance = Distance
         end
      end
   end

   local DropTargetPosition = DropTarget.Position
   local DropTargetVelocity = DropTarget.Velocity
   local DropTargetSqrSpeed = DropTargetVelocity.sqrMagnitude
   if DropTargetSqrSpeed <= 3 then
      -- Velocity is really small, use our current orientation
      DropTargetPosition = DropTargetPosition + C:ToWorld() * DropTargetOffset
   else
      -- Rotate offset
      DropTargetPosition = DropTargetPosition + Quaternion.LookRotation(DropTargetVelocity, Vector3.up) * DropTargetOffset
   end

   local Offset = PlanarVector(C:CoM(), DropTargetPosition)
   local Distance = Offset.magnitude
   local DodgeX,DodgeY,DodgeZ,Dodging = Dodge()
   DropAI_Closing = Distance > MaxWanderDistance
   if DropAI_Closing then
      if Dodging then
         -- Continue moving toward target, so don't take DodgeZ into account
         Offset = Offset + C:RightVector() * (DodgeX * VehicleRadius)
         DodgeAltitudeOffset = DodgeY * VehicleRadius
      else
         local Perp = Vector3.Cross(Offset / Distance, Vector3.up)
         Offset = Offset + Evade(ClosingEvasion, Perp)
         DodgeAltitudeOffset = nil
      end
      V.AdjustPosition(Avoidance(I, Offset, true))
      V.SetHeading(GetVectorAngle(Offset))
   else
      if Dodging then
         V.AdjustPosition(Avoidance(I, C:RightVector() * (DodgeX * VehicleRadius) + C:ForwardVector() * (DodgeZ * VehicleRadius), true))
         -- Don't adjust altitude since we might be right over the target
      else
         V.SetPosition(Avoidance(I, DropTargetPosition))
      end
      DodgeAltitudeOffset = nil
      if DropTargetSqrSpeed > 3 then
         V.SetHeading(GetVectorAngle(DropTargetVelocity))
      end
   end

   return true
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with MaxWanderDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      V.SetPosition(Avoidance(I, Waypoint))
      local Offset,_ = PlanarVector(C:CoM(), Waypoint)
      if Offset.magnitude >= MaxWanderDistance then
         V.SetHeading(GetVectorAngle(Offset))
      else
         V.SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= MaxWanderDistance then
         V.AdjustPosition(Avoidance(I, Offset, true))
         V.SetHeading(GetVectorAngle(Offset))
      end
   end
end

function DropAI_Update(I)
   V.Reset()

   if C:MovementMode() ~= "Fleet" then
      if not DropAI_Main(I) then
         DropAI_Reset()
         if ReturnToFormation then
            FormationMove(I)
         end
      end
   else
      DropAI_Reset()
      FormationMove(I)
   end
end
