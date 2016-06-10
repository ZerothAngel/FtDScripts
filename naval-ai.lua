-- Configuration
MinDistance = 500
MaxDistance = 750

AttackAngle = 90
AttackDrive = 1

ClosingAngle = 40
ClosingDrive = 1

EscapeAngle = 120
EscapeDrive = 1

AllowedAngleError = 2

MinDepth = 10
LookAheadTimes = { 1, 5, 10 }
LookAheadAngles = { -90, -45, -15, 0, 15, 45, 90 }

-- API constants
WATER = 0
LAND = 1
AIR = 2

YAWLEFT = 0
YAWRIGHT = 1
ROLLLEFT = 2
ROLLRIGHT = 3
NOSEUP = 4
NOSEDOWN = 5
INCREASE = 6
DECREASE = 7
MAINPROPULSION = 8

-- Private variables
Position = nil
Yaw = 0
Pitch = 0
Roll = 0
TargetInfo = nil

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
   if math.abs(angle) > AllowedAngleError then
      if angle > 0 then
         I:RequestControl(WATER, YAWRIGHT, 1)
      else
         I:RequestControl(WATER, YAWLEFT, 1)
      end
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

      local drive = 0
      if GetTarget(I) then
         I:TellAiThatWeAreTakingControl()
         drive = SetHeadingToTarget(I)
         SetSpeed(I, drive)
      end
   end
end
