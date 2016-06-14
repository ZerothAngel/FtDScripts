--! repair-ai
--@ avoidance commons pid
YawPID = PID.create(YawPIDValues[1], YawPIDValues[2], YawPIDValues[3], -1.0, 1.0)

FirstRun = nil
Origin = nil

TargetInfo = nil

ParentID = nil

function Imprint(I)
   ParentID = nil
   local Closest = math.huge
   for i = 0,I:GetFriendlyCount()-1 do
      local Friend = I:GetFriendlyInfo(i)
      local Direction = Friend.CenterOfMass - CoM
      local Distance = Direction.magnitude
      if Distance < Closest then
         Closest = Distance
         ParentID = Friend.Id
      end
   end
end

-- Called on first activation (not necessarily first Update)
function FirstRun(I)
   local __func__ = "FirstRun"

   FirstRun = nil

   Origin = CoM
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

function AdjustHeadingToParent(I)
   local Drive = 0
   local Parent = I:GetFriendlyInfoById(ParentID)
   if Parent and Parent.Valid then
      local ParentCoM = Parent.CenterOfMass + ParentOffset
      local Offset = ParentCoM - CoM
      local Distance = Offset.magnitude
      local Direction = Offset / Distance
      local RelativeVelocity = I:GetVelocityVector() - Parent.Velocity
      local RelativeSpeed = Vector3.Dot(RelativeVelocity, Direction)
      local InterceptTime = 10
      if RelativeSpeed > 0.0 then
         InterceptTime = Distance / RelativeSpeed
         InterceptTime = math.min(InterceptTime, 10)
      end

      local TargetPoint = ParentCoM + Parent.Velocity * InterceptTime
      if Distance > 10 then
         AdjustHeadingToPoint(I, TargetPoint)
         Drive = 1
      end
   end
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
   if (ActiateWhenOn and I.AIMode == 'on') or AIMode == 'combat' then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      -- Suppress default AI
      if AIMode == 'combat' then I:TellAiThatWeAreTakingControl() end

      local Drive = 0
      if GetTarget(I) then
         if not ParentID then
            Imprint(I)
         end
         if ParentID then
            Drive = AdjustHeadingToParent(I)
         end
      else
         ParentID = nil

         if ReturnToOrigin then
            local Target = Origin - CoM
            if Target.magnitude >= OriginMaxDistance then
               AdjustHeadingToPoint(I, Origin)
               Drive = ReturnDrive
            end
         end
      end
      SetDriveFraction(I, Drive)
   end
end
