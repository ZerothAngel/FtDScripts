--! naval-ai
--@ yawthrottle avoidance debug getselfinfo planarvector getbearingtopoint
--@ gettargetpositioninfo firstrun periodic
-- Naval AI module
Attacking = true
LastAttackTime = 0

Origin = nil
PerlinOffset = 0

function NavalAI_FirstRun(I)
   Origin = CoM
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(NavalAI_FirstRun)

-- Modifies bearing by some amount for evasive maneuvers
function Evade(I, Bearing, Evasion)
   local __func__ = "Evade"

   if AirRaidEvasion and TargetPositionInfo.Position.y >= AirRaidAboveAltitude then
      Evasion = AirRaidEvasion
   end

   if Evasion then
      local Evade = Bearing + Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * I:GetTimeSinceSpawn(), PerlinOffset) - 1.0)
      if Debugging then Debug(I, __func__, "Bearing %f Evade %f", Bearing, Evade) end
      return Evade
   else
      return Bearing
   end
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
      local Now = I:GetTimeSinceSpawn()
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
   Bearing = Evade(I, Bearing, Evasion)
   if Bearing > 180 then Bearing = Bearing - 360 end

   if Debugging then Debug(I, __func__, "State %s Drive %f Bearing %f", State, Drive, Bearing) end

   AdjustHeading(Avoidance(I, Bearing))

   return Drive
end

function NavalAI_Update(I)
   YawThrottle_Reset()

   local Drive = nil
   if GetTargetPositionInfo(I) then
      Drive = AdjustHeadingToTarget(I)
   elseif ReturnToOrigin then
      local Target,_ = PlanarVector(CoM, Origin)
      if Target.magnitude >= OriginMaxDistance then
         local Bearing = GetBearingToPoint(I, Origin)
         AdjustHeading(Avoidance(I, Bearing))
         Drive = ReturnDrive
      else
         Drive = 0
      end
   else
      -- Just continue along with avoidance active
      AdjustHeading(Avoidance(I, 0))
   end
   if Drive then
      SetThrottle(Drive)
   end
end

NavalAI = Periodic.create(UpdateRate, NavalAI_Update)

function Update(I)
   local AIMode = I.AIMode
   if not I:IsDocked() and ((ActivateWhenOn and AIMode == "on") or
                            AIMode == "combat") then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      NavalAI:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   end
end
