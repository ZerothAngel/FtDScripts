--@ commons pid spinnercontrol
-- Hover module
AltitudePID = PID.create(AltitudePIDConfig, CanReverseBlades and -30 or 0, 30)

LiftSpinners = SpinnerControl.create(Vector3.up, false, true, DediBladesAlwaysUp)

DesiredAltitude = 0

function SetAltitude(Alt)
   DesiredAltitude = Alt
end

function AdjustAltitude(Delta) -- luacheck: ignore 131
   DesiredAltitude = C:Altitude() + Delta
end

function Hover_Update(I)
   local CV = AltitudePID:Control(DesiredAltitude - C:Altitude())
   LiftSpinners:Classify(I)
   LiftSpinners:SetSpeed(I, CV)
end

function Hover_Disable(I)
   LiftSpinners:Classify(I)
   LiftSpinners:SetSpeed(I, 0)
end
