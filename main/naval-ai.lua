--! naval-ai
--@ avoidance commons pid
-- Global variables
YawPID = PID.create(YawPIDValues[1], YawPIDValues[2], YawPIDValues[3], -1.0, 1.0)

FirstRun = nil
Origin = nil
PerlinOffset = 0

TargetInfo = nil

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

-- Adjusts heading toward relative bearing
function AdjustHeading(I, Bearing)
   local __func__ = "AdjustHeading"

   Bearing = Avoidance(I, Bearing)
   local CV = YawPID:Control(Bearing) -- SetPoint of 0
   if Debugging then Debug(I, __func__, "Error = %f, CV = %f", Bearing, CV) end
   if CV > 0.0 then
      I:RequestControl(WATER, YAWRIGHT, CV)
   elseif CV < 0.0 then
      I:RequestControl(WATER, YAWLEFT, -CV)
   end
end

-- Adjust heading toward a given world point
function AdjustHeadingToPoint(I, Point)
   AdjustHeading(I, -I:GetTargetPositionInfoForPosition(0, Point.x, 0, Point.z).Azimuth)
end

-- Modifies bearing by some amount for evasive maneuvers
function Evade(I, Bearing, Evasion)
   local __func__ = "Evade"

   if AirRaidEvasion and TargetInfo.Position.y >= AirRaidAboveAltitude then
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

   local Distance = TargetInfo.GroundDistance
   local Bearing = -TargetInfo.Azimuth
   if Debugging then Debug(I, __func__, "Distance %f Bearing %f", Distance, Bearing) end

   local State,TargetAngle,Drive,Evasion = "escape",EscapeAngle,EscapeDrive,EscapeEvasion
   if Distance > MaxDistance then
      State = "closing"
      TargetAngle = ClosingAngle
      Drive = ClosingDrive
      Evasion = ClosingEvasion
   elseif Distance > MinDistance then
      State = "attack"
      TargetAngle = AttackAngle
      Drive = AttackDrive
      Evasion = AttackEvasion
   end

   Bearing = Bearing - sign(Bearing)*TargetAngle
   Bearing = Evade(I, Bearing, Evasion)
   if Bearing > 180 then Bearing = Bearing - 360 end

   if Debugging then Debug(I, __func__, "State %s Drive %f Bearing %f", State, Drive, Bearing) end

   AdjustHeading(I, Bearing)

   return Drive
end

-- Sets throttle
function SetDriveFraction(I, Drive)
   I:RequestControl(WATER, MAINPROPULSION, Drive)
end

-- Finds first valid target on first mainframe
function GetTarget(I)
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         TargetInfo = I:GetTargetPositionInfo(mindex, tindex)
         if TargetInfo.Valid then return true end
      end
   end
   TargetInfo = nil
   return false
end

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      local Drive = 0
      if GetTarget(I) then
         Drive = AdjustHeadingToTarget(I)
      elseif ReturnToOrigin then
         local Target,_ = PlanarVector(CoM, Origin)
         if Target.magnitude >= OriginMaxDistance then
            AdjustHeadingToPoint(I, Origin)
            Drive = ReturnDrive
         end
      end
      SetDriveFraction(I, Drive)
   end
end
