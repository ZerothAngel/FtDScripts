--! tiltspinnertest
--@ commons periodic tiltspinner
MyTiltSpinner = TiltSpinner.new(Vector3.right, TiltSpinnerPIDConfig)

function TiltSpinnerTest_Update(I)
   MyTiltSpinner:SetAngle(TestAngle)
   MyTiltSpinner:Update(I)
end

TiltSpinnerTest = Periodic.new(UpdateRate, TiltSpinnerTest_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      if ActivateWhen[I.AIMode] then
         TiltSpinnerTest:Tick(I)
      end
   else
      MyTiltSpinner:Disable(I)
   end
end
