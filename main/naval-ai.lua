--! naval-ai
--@ commons pid
-- Private variables
Position = nil
Yaw = 0
Pitch = 0
Roll = 0
YawPID = PID.create(YawPIDValues[1], YawPIDValues[2], YawPIDValues[3], -1.0, 1.0)

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

function Avoidance(I, Azimuth)
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
      FAvoid = FAvoid * FMin * FriendlyAvoidanceWeight / FCount
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
      TAvoid = TAvoid * TMin * TerrainAvoidanceWeight
   end

   --I:LogToHud(string.format("TCount %d TAvoid %s", TCount, tostring(TAvoid)))

   if (FCount + TCount) == 0 then
      return Azimuth
   else
      -- Current target as given by Azimuth
      local NewTarget = Quaternion.Euler(0, Azimuth, 0) * Vector3.forward
      -- Sum of all avoidance vectors
      NewTarget = NewTarget + FAvoid + TAvoid

      -- To world coordinates
      NewTarget = Position + Quaternion.Euler(0, Yaw, 0) * NewTarget
      -- Vector3.Angle not working?
      return -I:GetTargetPositionInfoForPosition(0, NewTarget.x, 0, NewTarget.z).Azimuth
   end
end

function SetHeading(I, Azimuth)
   Azimuth = Avoidance(I, Azimuth)
   local CV = YawPID:Control(Azimuth)
   --I:LogToHud(string.format("Error = %f, CV = %f", Azimuth, CV))
   if CV > 0.0 then
      I:RequestControl(WATER, YAWRIGHT, CV)
   elseif CV < 0.0 then
      I:RequestControl(WATER, YAWLEFT, -CV)
   end
end

function SetHeadingToTarget(I, TargetInfo)
   local Distance = TargetInfo.GroundDistance
   local Azimuth = -TargetInfo.Azimuth
   --I:LogToHud(string.format("Distance %f Azimuth %f", Distance, Azimuth))

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

   Azimuth = Azimuth - sign(Azimuth)*TargetAngle
   if Azimuth > 180 then Azimuth = Azimuth - 360 end

   --I:LogToHud(string.format("State %s Drive %f Azimuth %f", State, Drive, Azimuth))

   SetHeading(I, Azimuth)

   return Drive
end

function SetSpeed(I, Drive)
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
   if I.AIMode == 'combat' then
      GetSelfInfo(I)

      local TargetInfo = GetTarget(I)
      if TargetInfo then
         I:TellAiThatWeAreTakingControl()
         local Drive = SetHeadingToTarget(I, TargetInfo)
         SetSpeed(I, Drive)
      end
   end
end
