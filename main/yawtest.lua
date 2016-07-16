--! yawtest
--@ yawthrottle getselfinfo firstrun periodic
MyHeading = -90
LastTurn = nil

ThrottleIndex = 0

function YawTest_Update(I)
   YawThrottle_Reset()

   MyHeading = (MyHeading + 90) % 360
   I:LogToHud(string.format("New heading! %f degrees", MyHeading))
   SetHeading(MyHeading)
   if VaryThrottle then
      ThrottleIndex = ThrottleIndex + 1
      SetThrottle(ThrottleSettings[ThrottleIndex])
      ThrottleIndex = ThrottleIndex % #ThrottleSettings
   end
   LastTurn = { I:GetTimeSinceSpawn(), CoM }
end

YawTest = Periodic.create(UpdateRate, YawTest_Update)

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      if LastTurn and Mathf.DeltaAngle(Yaw, MyHeading) < 0.1 then
         local DeltaTime = I:GetTimeSinceSpawn() - LastTurn[1]
         local Distance = (CoM - LastTurn[2]).magnitude
         local Message = string.format("Time: %.2f s, Distance: %.2f m", DeltaTime, Distance)
         I:Log(Message)
         I:LogToHud(Message)
         LastTurn = nil
      end

      YawTest:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   end
end
