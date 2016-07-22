--! gunship
--@ getvectorangle planarvector getselfinfo firstrun periodic
--@ gettargetpositioninfo fiveaxis hover
-- Gunship AI module
Origin = nil
PerlinOffset = 0

function GunshipAI_FirstRun(I)
   Origin = CoM
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(GunshipAI_FirstRun)

-- Modifies bearing by some amount for evasive maneuvers
function Evade(I, Perp, Evasion)
   if Evasion then
      return Perp * Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * I:GetTimeSinceSpawn(), PerlinOffset) - 1.0)
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
   SetPitch(TargetPitch)
end

function GunshipAI_Update(I)
   FiveAxis_Reset()

   if GetTargetPositionInfo(I) then
      AdjustPositionToTarget(I)
   elseif ReturnToOrigin then
      local Offset,_ = PlanarVector(CoM, Origin)
      if Offset.magnitude >= OriginMaxDistance then
         SetHeading(GetVectorAngle(Offset))
         SetPosition(Origin)
      end
      SetPitch(0)
   end
end

Hover = Periodic.create(UpdateRate, Hover_Control)
GunshipAI = Periodic.create(UpdateRate, GunshipAI_Update, 1)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and AIMode ~= "off" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      Hover:Tick(I)

      if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then
         GunshipAI:Tick(I)

         -- Suppress default AI
         if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end
      else
         FiveAxis_Reset()
      end

      Hover_Update(I)
      FiveAxis_Update(I)
   end
end
