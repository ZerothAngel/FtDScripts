--@ commons getvectorangle planarvector dodge3d evasion
-- Drop AI module
DodgeAltitudeOffset = nil
DropTargetID = nil

-- Global that downstream modules can check
DropAI_Closing = false

function DropAI_GatherTargets()
   local TargetsByPriority = {}
   local TargetsById = {}

   for _,Target in pairs(C:Targets()) do
      table.insert(TargetsByPriority, Target)
      TargetsById[Target.Id] = Target
   end

   return TargetsByPriority, TargetsById
end

function DropAI_Reset()
   DropTargetID = nil
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
      for _,Target in pairs(TargetsByPriority) do
         local Offset = Target.Position - C:CoM()
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
      DropTargetPosition = DropTargetPosition + C:ToGlobal() * DropTargetOffset
   else
      -- Rotate offset
      DropTargetPosition = DropTargetPosition + Quaternion.LookRotation(DropTargetVelocity, Vector3.up) * DropTargetOffset
   end

   local Offset = PlanarVector(C:CoM(), DropTargetPosition)
   local Distance = Offset.magnitude
   local DodgeX,DodgeY,DodgeZ,Dodging = Dodge(I)
   DropAI_Closing = Distance > OriginMaxDistance
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
      AdjustPosition(Offset)
      SetHeading(GetVectorAngle(Offset))
   else
      if Dodging then
         AdjustPosition(C:RightVector() * (DodgeX * VehicleRadius) + C:ForwardVector() * (DodgeZ * VehicleRadius))
         -- Don't adjust altitude since we might be right over the target
      else
         SetPosition(DropTargetPosition)
      end
      DodgeAltitudeOffset = nil
      if DropTargetSqrSpeed > 3 then
         SetHeading(GetVectorAngle(DropTargetVelocity))
      end
   end

   return true
end

function FormationMove(I)
   local Flagship = I.Fleet.Flagship
   if not I.IsFlagship and Flagship.Valid then
      local FlagshipRotation = Flagship.Rotation
      -- NB We don't bother with OriginMaxDistance
      -- This leads to tighter formations.
      local Waypoint = Flagship.ReferencePosition + FlagshipRotation * I.IdealFleetPosition
      SetPosition(Waypoint)
      local Offset,_ = PlanarVector(C:CoM(), Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         SetHeading(GetVectorAngle(Offset))
      else
         SetHeading(GetVectorAngle((FlagshipRotation * I.IdealFleetRotation) * Vector3.forward))
      end
   else
      -- Head to fleet waypoint
      local Offset,_ = PlanarVector(C:CoM(), I.Waypoint)
      if Offset.magnitude >= OriginMaxDistance then
         AdjustPosition(Offset)
         SetHeading(GetVectorAngle(Offset))
      end
   end
end

function DropAI_Update(I)
   Control_Reset()

   local AIMode = I.AIMode
   if AIMode ~= "fleetmove" then
      if not DropAI_Main(I) then
         DropAI_Reset()
         if ReturnToOrigin then
            FormationMove(I)
         end
      end
   else
      DropAI_Reset()
      FormationMove(I)
   end
end
