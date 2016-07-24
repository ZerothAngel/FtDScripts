--! yawtest
--@ yawthrottle getselfinfo firstrun eventdriver
MyHeading = -90
LastTurn = nil

ThrottleIndex = 0

YawTest = EventDriver.create()

function YawTest_FirstRun(I)
   YawTest:Schedule(0, YawTest_Throttle)
end
AddFirstRun(YawTest_FirstRun)

function YawTest_Throttle(I)
   if VaryThrottle then
      ThrottleIndex = ThrottleIndex + 1
      local Throttle = ThrottleSettings[ThrottleIndex]
      ThrottleIndex = ThrottleIndex % #ThrottleSettings

      I:LogToHud(string.format("New throttle! %.0f%%", Throttle * 100))
      SetThrottle(Throttle)

      -- Get up to speed before changing heading
      YawTest:Schedule(ThrottleDelay, YawTest_Heading)
   else
      ResetThrottle()

      YawTest:Schedule(0, YawTest_Heading)
   end
end

function YawTest_Heading(I)
   MyHeading = (MyHeading + 90) % 360
   I:LogToHud(string.format("New heading! %f degrees", MyHeading))
   SetHeading(MyHeading)
   LastTurn = { I:GetTimeSinceSpawn(), CoM }

   YawTest:Schedule(HeadingDelay, YawTest_Throttle)
end

function Update(I)
   if ActivateWhen[I.AIMode] then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if LastTurn and math.abs(Mathf.DeltaAngle(Yaw, MyHeading)) < 0.1 then
         local DeltaTime = I:GetTimeSinceSpawn() - LastTurn[1]
         local Distance = (CoM - LastTurn[2]).magnitude
         local Message = string.format("Time: %.2f s, Distance: %.2f m", DeltaTime, Distance)
         I:Log(Message)
         I:LogToHud(Message)
         LastTurn = nil
      end

      YawTest:Tick(I)

      -- Suppress default AI
      I:TellAiThatWeAreTakingControl()

      YawThrottle_Update(I)
   end
end
