--! naval-ai
--@ commons pid
-- Private variables
Position = nil
Yaw = 0
Pitch = 0
Roll = 0
YawPID = PID.create(YawPIDValues[1], YawPIDValues[2], YawPIDValues[3], -1.0, 1.0)

FirstRun = true
Origin = nil

function GetSelfInfo(I)
   Position = I:GetConstructPosition()

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

   --I:LogToHud(string.format("Yaw %f Pitch %f Roll %f", Yaw, Pitch, Roll))
end

function sign(n)
   if n < 0 then
      return -1
   elseif n > 0 then
      return 1
   else
      return 0
   end
end

function Avoidance(I, Bearing)
   -- Look for nearby friendlies
   local CoM = I:GetConstructCenterOfMass()
   local FCount,FAvoid,FMin = 0,Vector3.zero,math.huge
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      if Friend.Valid and Friend.CenterOfMass.y < FriendlyIgnoreAbove then
         local Direction = Friend.CenterOfMass - CoM
         local Distance = Direction.magnitude
         if Distance < FriendlyMinDistance then
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

   --I:LogToHud(string.format("FCount %d FAvoid %s", FCount, tostring(FAvoid)))

   -- For now, we scan in front rather than take actual velocity into account
   local ForwardOffset = Vector3(0, 0, I:GetConstructMaxDimensions().z)
   local Speed = I:GetVelocityMagnitude()
   local TCount,TAvoid,TMin = 0,Vector3.zero,math.huge
   for i,t in pairs(LookAheadTimes) do
      -- Distance to look
      local Forward = ForwardOffset + Vector3.forward * t * Speed
      -- Each set of angles for each look ahead time are weighted differently
      local TimeCount,TimeAvoid = 0,Vector3.zero
      for j,a in pairs(LookAheadAngles) do
         local pos = Quaternion.Euler(0, a, 0) * Forward
         if I:GetTerrainAltitudeForLocalPosition(pos) > -MinDepth then
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

   --I:LogToHud(string.format("TCount %d TAvoid %s", TCount, tostring(TAvoid)))

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

function AdjustHeading(I, Bearing)
   Bearing = Avoidance(I, Bearing)
   local CV = YawPID:Control(Bearing) -- SetPoint of 0
   --I:LogToHud(string.format("Error = %f, CV = %f", Bearing, CV))
   if CV > 0.0 then
      I:RequestControl(WATER, YAWRIGHT, CV)
   elseif CV < 0.0 then
      I:RequestControl(WATER, YAWLEFT, -CV)
   end
end

function AdjustHeadingToPoint(I, Point)
   AdjustHeading(I, -I:GetTargetPositionInfoForPosition(0, Point.x, 0, Point.z).Azimuth)
end

function AdjustHeadingToTarget(I, TargetInfo)
   local Distance = TargetInfo.GroundDistance
   local Bearing = -TargetInfo.Azimuth
   --I:LogToHud(string.format("Distance %f Bearing %f", Distance, Bearing))

   local State,TargetAngle,Drive = "escape",EscapeAngle,EscapeDrive
   if Distance > MaxDistance then
      State = "closing"
      TargetAngle = ClosingAngle
      Drive = ClosingDrive
   elseif Distance > MinDistance then
      State = "attack"
      TargetAngle = AttackAngle
      Drive = AttackDrive
   end

   Bearing = Bearing - sign(Bearing)*TargetAngle
   if Bearing > 180 then Bearing = Bearing - 360 end

   --I:LogToHud(string.format("State %s Drive %f Bearing %f", State, Drive, Bearing))

   AdjustHeading(I, Bearing)

   return Drive
end

function SetDriveFraction(I, Drive)
   I:RequestControl(WATER, MAINPROPULSION, Drive)
end

function GetTarget(I)
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         local TargetInfo = I:GetTargetPositionInfo(mindex, tindex)
         if TargetInfo.Valid then return TargetInfo end
      end
   end
   return nil
end

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      if FirstRun then
         FirstRun = false
         Origin = Position
      end

      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      local Drive = 0
      local TargetInfo = GetTarget(I)
      if TargetInfo then
         Drive = AdjustHeadingToTarget(I, TargetInfo)
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
