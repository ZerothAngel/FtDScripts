--! naval-ai
--@ yawthrottle avoidance debug getselfinfo planarvector getbearingtopoint
--@ gettargetpositioninfo periodic
-- Naval AI module
Attacking = true
LastAttackTime = 0

FirstRun = nil
Origin = nil
PerlinOffset = 0

-- Called on first activation (not necessarily first Update)
function FirstRun(I)
   local __func__ = "FirstRun"

   FirstRun = nil

   Origin = CoM
   PerlinOffset = 1000.0 * math.random()

   if Debugging then Debug(I, __func__, "PerlinOffset %f", PerlinOffset) end

   AvoidanceFirstRun(I)
end

-- Because I didn't realize Mathf.Sign exists.
function sign(n)
   if n < 0 then
      return -1
   elseif n > 0 then
      return 1
   else
      return 0
   end
end

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

   Bearing = Bearing - sign(Bearing)*TargetAngle
   Bearing = Evade(I, Bearing, Evasion)
   if Bearing > 180 then Bearing = Bearing - 360 end

   if Debugging then Debug(I, __func__, "State %s Drive %f Bearing %f", State, Drive, Bearing) end

   AdjustHeading(Avoidance(I, Bearing))

   return Drive
end

function NavalAI_Update(I)
   if FirstRun then FirstRun(I) end

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

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      NavalAI:Tick(I)

      YawThrottle_Update(I)
   end
end
