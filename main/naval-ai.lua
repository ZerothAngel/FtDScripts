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

function AvoidTerrain(I, angle)
   -- For now, we scan in front rather than take actual velocity into account
   local offset = Vector3(0, 0, I:GetConstructMaxDimensions().z)
   local velocity = I:GetVelocityMagnitude()
   local count,avoid = 0,Vector3.zero
   for i,t in pairs(LookAheadTimes) do
      for j,a in pairs(LookAheadAngles) do
         local pos = offset + Vector3.forward * t * velocity
         pos = Quaternion.Euler(0, a, 0) * pos
         if I:GetTerrainAltitudeForLocalPosition(pos) > -MinDepth then
            count = count + 1
            avoid = avoid - pos
         end
      end
   end

   --I:LogToHud("count "..count.." avoid "..tostring(avoid))

   if count == 0 then
      return angle
   else
      -- To world coordinates
      avoid = Position + Quaternion.Euler(0, Yaw, 0) * avoid
      -- Vector3.Angle not working?
      return -I:GetTargetPositionInfoForPosition(0, avoid.x, 0, avoid.z).Azimuth
   end
end

function SetHeading(I, angle)
   angle = AvoidTerrain(I, angle)
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
