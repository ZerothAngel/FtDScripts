--! tanktest
--@ commons control firstrun eventdriver tanksteer
MyHeading = -90
LastTurn = nil

ThrottleIndex = 0

TankTest = EventDriver.create()

function TankTest_FirstRun(_)
   TankTest:Schedule(0, TankTest_Throttle)
end
AddFirstRun(TankTest_FirstRun)

function TankTest_Throttle(I)
   if VaryThrottle then
      ThrottleIndex = ThrottleIndex + 1
      local Throttle = ThrottleSettings[ThrottleIndex]
      ThrottleIndex = ThrottleIndex % #ThrottleSettings

      I:LogToHud(string.format("New throttle! %.0f%%", Throttle * 100))
      V.SetThrottle(Throttle)

      -- Get up to speed before changing heading
      TankTest:Schedule(ThrottleDelay, TankTest_Heading)
   else
      V.ResetThrottle()

      TankTest:Schedule(0, TankTest_Heading)
   end
end

function TankTest_Heading(I)
   MyHeading = (MyHeading + 90) % 360
   I:LogToHud(string.format("New heading! %f degrees", MyHeading))
   V.SetHeading(MyHeading)
   LastTurn = { C:Now(), C:CoM() }

   TankTest:Schedule(HeadingDelay, TankTest_Throttle)
end

SelectHeadingImpl(TankSteer)
SelectThrottleImpl(TankSteer)

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

         TankTest:Tick(I)

         -- Suppress default AI
         I:TellAiThatWeAreTakingControl()
      else
         V.Reset()
         TankSteer.Release(I)
      end

      TankSteer.Update(I)
   else
      TankSteer.Disable(I)
   end
end
