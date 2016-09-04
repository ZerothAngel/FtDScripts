--! dediblademaintainer
--@ manualcontroller spinnercontrol periodic
ThrottleController = ManualController.create(ThrottleDriveMaintainerFacing)
PropulsionSpinners = SpinnerControl.create(Vector3.forward, UseSpinners, UseDediBlades)

DesiredThrottle = 0

function DediBladeMaintainer_Control(I)
   local Throttle = ThrottleWhen[I.AIMode]
   if Throttle then
      DesiredThrottle = Throttle
   else
      DesiredThrottle = ThrottleController:GetReading(I)
   end
end

function DediBladeMaintainer_Update(I)
   PropulsionSpinners:Classify(I)
   PropulsionSpinners:SetSpeed(I, DesiredThrottle * 30)
end

DediBladeMaintainer = Periodic.create(UpdateRate, DediBladeMaintainer_Control)

function Update(I)
   if not I:IsDocked() and ActivateWhen[I.AIMode] then
      DediBladeMaintainer:Tick(I)

      DediBladeMaintainer_Update(I)
   end
end
