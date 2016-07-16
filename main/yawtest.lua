--! yawtest
--@ yawthrottle getselfinfo firstrun periodic
MyHeading = -90

function YawTest_Update(I)
   YawThrottle_Reset()

   MyHeading = (MyHeading + 90) % 360
   I:LogToHud(string.format("New heading! %f degrees", MyHeading))
   SetHeading(MyHeading)
end

YawTest = Periodic.create(UpdateRate, YawTest_Update)

function Update(I)
   local AIMode = I.AIMode
   if (ActivateWhenOn and AIMode == "on") or AIMode == "combat" then
      GetSelfInfo(I)

      if FirstRun then FirstRun(I) end

      YawTest:Tick(I)

      -- Suppress default AI
      if AIMode == "combat" then I:TellAiThatWeAreTakingControl() end

      YawThrottle_Update(I)
   end
end
