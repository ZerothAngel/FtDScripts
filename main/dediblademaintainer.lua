--! dediblademaintainer
--@ periodic drivemaintainer spinnercontrol
ThrottleController = DriveMaintainer.create(ThrottleDriveMaintainerFacing)
PropulsionSpinners = SpinnerControl.create(Vector3.forward, UseSpinners, UseDediBlades)

DesiredThrottle = 0

function DediBladeMaintainer_Control(I)
   local Throttle = ThrottleWhen[I.AIMode]
   if Throttle then
      DesiredThrottle = Throttle
   else
      DesiredThrottle = ThrottleController:GetThrottle(I)
   end
end

function DediBladeMaintainer_Update(I)
   -- Note: Standard propulsion can link up to the drive maintainer normally
   PropulsionSpinners:Classify(I)
   PropulsionSpinners:SetSpeed(I, DesiredThrottle * 30)
end

function DediBladeMaintainer_Disable(I)
   PropulsionSpinners:Classify(I)
   PropulsionSpinners:SetSpeed(I, 0)
end

DediBladeMaintainer = Periodic.create(UpdateRate, DediBladeMaintainer_Control)

function Update(I) -- luacheck: ignore 131
   if ActivateWhen[I.AIMode] then
      if not I:IsDocked() then
         DediBladeMaintainer:Tick(I)

         DediBladeMaintainer_Update(I)
      else
         DediBladeMaintainer_Disable(I)
      end
   end
end
