--! naval-ai
--@ commons pid
-- Global variables
Position = nil
CoM = nil
Altitude = 0
Yaw = 0
Pitch = 0
Roll = 0
YawPID = PID.create(YawPIDValues[1], YawPIDValues[2], YawPIDValues[3], -1.0, 1.0)

FirstRun = nil
Origin = nil
PerlinOffset = 0

TargetInfo = nil

-- Called on first activation (not necessarily first Update)
function FirstRun(I)
   local __func__ = "FirstRun"

   FirstRun = nil

   Origin = Position
   PerlinOffset = 1000.0 * math.random()

   if Debugging then Debug(I, __func__, "PerlinOffset %f", PerlinOffset) end
end

-- Grab & save info about the ship, adjust them so they match
-- the HUD's values.
function GetSelfInfo(I)
   local __func__ = "GetSelfInfo"

   Position = I:GetConstructPosition()
   CoM = I:GetConstructCenterOfMass()
   Altitude = CoM.y

   Yaw = I:GetConstructYaw()

   Pitch = I:GetConstructPitch()

   if Pitch > 180 then
      Pitch = 360 - Pitch
   else
      Pitch = -Pitch
   end

   Roll = I:GetConstructRoll()
   if Roll > 180 then
      Roll = Roll - 360
   end

   if Debugging then Debug(I, __func__, "Yaw %f Pitch %f Roll %f Alt %f", Yaw, Pitch, Roll, Altitude) end
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

-- Modifies bearing to avoid any friendlies & terrain
function Avoidance(I, Bearing)
   local __func__ = "Avoidance"

   -- Our own dimensions
   local MaxDim = I:GetConstructMaxDimensions()
   ForwardOffset = Vector3(0, 0, MaxDim.z)

   -- Required clearance above and below
   local Height = MaxDim.y - I:GetConstructMinDimensions().y
   local UpperEdge = Altitude + Height * ClearanceFactor
   local LowerEdge = Altitude - Height * ClearanceFactor

   -- Look for nearby friendlies
   local FCount,FAvoid,FMin = 0,Vector3.zero,math.huge
   local MinDistance = TargetInfo and FriendlyMinDistanceCombat or FriendlyMinDistanceIdle
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      local FriendPosition = Friend.ReferencePosition
      -- Only consider friendlies within our altitude range
      local FriendAlt = FriendPosition.y
      if Friend.Valid and ((FriendAlt+Friend.NegativeSize.y) <= UpperEdge and
                           (FriendAlt+Friend.PositiveSize.y) >= LowerEdge) then
         local Direction = FriendPosition - Position
         local Distance = Direction.magnitude
         if Distance < MinDistance then
            -- Don't stand so close to me
            FCount = FCount + 1
            FAvoid = FAvoid - Direction.normalized / Distance
            FMin = math.min(FMin, Distance)
         end
      end
   end
   if FCount > 0 then
      -- Normalize according to closest friend and average out
      FAvoid = FAvoid * FMin * FriendlyAvoidanceWeight / FCount
      -- NB Vector is world vector not local
   end

   if Debugging then Debug(I, __func__, "FCount %d FAvoid %s", FCount, tostring(FAvoid)) end

   -- For now, we scan in front rather than take actual velocity into account
   local Speed = I:GetVelocityMagnitude()
   local TCount,TAvoid,TMin = 0,Vector3.zero,math.huge
   for i,t in pairs(LookAheadTimes) do
      -- Distance to look
      local Forward = ForwardOffset + Vector3.forward * t * Speed
      -- Each set of angles for each look ahead time are weighted differently
      local TimeCount,TimeAvoid = 0,Vector3.zero
      for j,a in pairs(LookAheadAngles) do
         local pos = Quaternion.Euler(0, a, 0) * Forward
         if I:GetTerrainAltitudeForLocalPosition(pos) > LowerEdge then
            TimeCount = TimeCount + 1
            TimeAvoid = TimeAvoid - pos.normalized
         end
      end
      if TimeCount > 0 then
         -- NB Smaller time -> greater magnitude of average vector
         TimeAvoid = TimeAvoid / (t * TimeCount)
         -- Accumulate overall count/vector
         TCount = TCount + TimeCount
         TAvoid = TAvoid + TimeAvoid
         TMin = math.min(TMin, t)
      end
   end
   if TCount > 0 then
      -- Normalize according to smallest time
      TAvoid = TAvoid * TMin * TerrainAvoidanceWeight
      -- NB Vector is local vector
   end

   if Debugging then Debug(I, __func__, "TCount %d TAvoid %s", TCount, tostring(TAvoid)) end

   if (FCount + TCount) == 0 then
      return Bearing
   else
      -- Current target as given by Bearing
      local NewTarget = Quaternion.Euler(0, Bearing, 0) * Vector3.forward
      -- Sum of all local avoidance vectors
      NewTarget = NewTarget + TAvoid

      -- To world coordinates, and add world vectors
      NewTarget = Position + Quaternion.Euler(0, Yaw, 0) * NewTarget + FAvoid
      -- Determine new bearing
      return -I:GetTargetPositionInfoForPosition(0, NewTarget.x, 0, NewTarget.z).Azimuth
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
         local Target = Origin - Position
         if Target.magnitude >= OriginMaxDistance then
            AdjustHeadingToPoint(I, Origin)
            Drive = ReturnDrive
         end
      end
      SetDriveFraction(I, Drive)
   end
end
