--@ commons pid spinnercontrol
-- Hover module
AltitudePID = PID.create(AltitudePIDConfig, CanReverseBlades and -30 or 0, 30)

LiftSpinners = SpinnerControl.create(Vector3.up, false, true, DediBladesAlwaysUp)

DesiredAltitude = 0

function SetAltitude(Alt, MinAlt)
   if not MinAlt then MinAlt = -math.huge end
   DesiredAltitude = math.max(Alt, MinAlt)
end

function AdjustAltitude(Delta, MinAlt) -- luacheck: ignore 131
   SetAltitude(C:Altitude() + Delta, MinAlt)
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
