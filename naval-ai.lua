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
   Position = I:GetConstructCenterOfMass()

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
      
function SetHeading(I)
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

   if math.abs(targetAngle) > AllowedAngleError then
      if targetAngle > 0 then
         I:RequestControl(WATER, YAWRIGHT, 1)
      else
         I:RequestControl(WATER, YAWLEFT, 1)
      end
   end

   return drive
end

function SetSpeed(I, drive)
   I:RequestControl(WATER, MAINPROPULSION, drive)
end

function SetTarget(I)
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
      --GetSelfInfo(I)

      local drive = 0
      if SetTarget(I) then
         I:TellAiThatWeAreTakingControl()
         drive = SetHeading(I)
         SetSpeed(I, drive)
      end
   end
end
