--! yawtest
--@ commons control firstrun eventdriver sixdof ytdefaults
MyHeading = -90
LastTurn = nil

ThrottleIndex = 0

YawTest = EventDriver.create()

function YawTest_FirstRun(_)
   YawTest:Schedule(0, YawTest_Throttle)
end
AddFirstRun(YawTest_FirstRun)

function YawTest_Throttle(I)
   if VaryThrottle then
      ThrottleIndex = ThrottleIndex + 1
      local Throttle = ThrottleSettings[ThrottleIndex]
      ThrottleIndex = ThrottleIndex % #ThrottleSettings

      I:LogToHud(string.format("New throttle! %.0f%%", Throttle * 100))
      V.SetThrottle(Throttle)

      -- Get up to speed before changing heading
      YawTest:Schedule(ThrottleDelay, YawTest_Heading)
   else
      V.ResetThrottle()

      YawTest:Schedule(0, YawTest_Heading)
   end
end

function YawTest_Heading(I)
   MyHeading = (MyHeading + 90) % 360
   I:LogToHud(string.format("New heading! %f degrees", MyHeading))
   V.SetHeading(MyHeading)
   LastTurn = { C:Now(), C:CoM() }

   YawTest:Schedule(HeadingDelay, YawTest_Throttle)
end

SelectHeadingImpl(SixDoF)
SelectThrottleImpl(SixDoF)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         if LastTurn and math.abs(Mathf.DeltaAngle(C:Yaw(), MyHeading)) < 0.1 then
            local DeltaTime = C:Now() - LastTurn[1]
            local SqrDistance = (C:CoM() - LastTurn[2]).sqrMagnitude
            local Radius = math.sqrt(SqrDistance / 2)
            local Message = string.format("Time: %.2f s, Radius: %.2f m", DeltaTime, Radius)
            I:Log(Message)
            I:LogToHud(Message)
            LastTurn = nil
         end

         YawTest:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         V.Reset()
      end

      SixDoF.Update(I)
   else
      SixDoF.Disable(I)
   end
end
