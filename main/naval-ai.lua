--! naval-ai
--@ commons pid
-- Private variables
Position = nil
Yaw = 0
Pitch = 0
Roll = 0
TargetInfo = nil
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

   --I:Log("Yaw "..Yaw)
   --I:Log("Pitch"..Pitch)
   --I:Log("Roll"..Roll)
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

function Avoidance(I, angle)
   -- Look for nearby friendlies
   local CoM = I:GetConstructCenterOfMass()
   local f_count,f_avoid = 0,Vector3.zero
   local min_dist = math.huge
   for i = 0,I:GetFriendlyCount()-1 do
      local friend = I:GetFriendlyInfo(i)
      if friend.Valid and friend.CenterOfMass.y < FriendlyIgnoreAbove then
         local direction = friend.CenterOfMass - CoM
         local distance = direction.magnitude
         if distance < FriendlyMinDistance then
            -- Don't stand so close to me
            f_count = f_count + 1
            f_avoid = f_avoid - direction.normalized / distance
            min_dist = math.min(min_dist, distance)
         end
      end
   end
   if f_count > 0 then
      f_avoid = f_avoid * min_dist * FriendlyAvoidanceWeight / f_count
   end

   --I:LogToHud(string.format("f_count = %d, f_avoid = %s", f_count, tostring(f_avoid)))

   -- For now, we scan in front rather than take actual velocity into account
   local offset = Vector3(0, 0, I:GetConstructMaxDimensions().z)
   local velocity = I:GetVelocityMagnitude()
   local t_count,min_time = 0,math.huge
   local t_avoid = Vector3.zero
   for i,t in pairs(LookAheadTimes) do
      local forward = offset + Vector3.forward * t * velocity
      local time_count,time_avoid = 0,Vector3.zero
      for j,a in pairs(LookAheadAngles) do
         local pos = Quaternion.Euler(0, a, 0) * forward
         if I:GetTerrainAltitudeForLocalPosition(pos) > -MinDepth then
            time_count = time_count + 1
            time_avoid = time_avoid - pos.normalized
         end
      end
      if time_count > 0 then
         time_avoid = time_avoid / (t * time_count)
         t_count = t_count + time_count
         t_avoid = t_avoid + time_avoid
         min_time = math.min(min_time, t)
      end
   end
   if t_count > 0 then
      t_avoid = t_avoid * min_time * TerrainAvoidanceWeight
   end

   --I:LogToHud("count "..count.." avoid "..tostring(avoid))

   if (f_count + t_count) == 0 then
      return angle
   else
      local target = Quaternion.Euler(0, angle, 0) * Vector3.forward
      target = target + f_avoid + t_avoid

      -- To world coordinates
      target = Position + Quaternion.Euler(0, Yaw, 0) * target
      -- Vector3.Angle not working?
      return -I:GetTargetPositionInfoForPosition(0, target.x, 0, target.z).Azimuth
   end
end

function SetHeading(I, angle)
   angle = Avoidance(I, angle)
   local CV = YawPID:Control(angle)
   --I:LogToHud(string.format("error = %f, CV = %f", angle, CV))
   if CV > 0.0 then
      I:RequestControl(WATER, YAWRIGHT, CV)
   elseif CV < 0.0 then
      I:RequestControl(WATER, YAWLEFT, -CV)
   end
end

function SetHeadingToTarget(I)
   local distance = TargetInfo.GroundDistance
   local azimuth = -TargetInfo.Azimuth
   --I:LogToHud("Distance "..distance.." Azimuth "..azimuth)
   local state,targetAngle,drive = "escape",0,0
   if distance > MaxDistance then
      state = "closing"
      targetAngle = ClosingAngle
      drive = ClosingDrive
   elseif distance > MinDistance then
      state = "attack"
      targetAngle = AttackAngle
      drive = AttackDrive
   else
      state = "escape"
      targetAngle = EscapeAngle
      drive = EscapeDrive
   end

   targetAngle = azimuth - sign(azimuth)*targetAngle
   if targetAngle > 180 then targetAngle = targetAngle - 360 end

   --I:LogToHud("State "..state.." Drive "..drive.." TargetAngle "..targetAngle)

   SetHeading(I, targetAngle)

   return drive
end

function SetSpeed(I, drive)
   I:RequestControl(WATER, MAINPROPULSION, drive)
end

function GetTarget(I)
   TargetInfo = nil
   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         TargetInfo = I:GetTargetPositionInfo(mindex, tindex)
         if TargetInfo.Valid then return true end
      end
   end
   return false
end

function Update(I)
   if I.AIMode == 'combat' then
      GetSelfInfo(I)

      if GetTarget(I) then
         I:TellAiThatWeAreTakingControl()
         local drive = SetHeadingToTarget(I)
         SetSpeed(I, drive)
      end
   end
end
