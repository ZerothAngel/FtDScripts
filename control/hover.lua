--@ pid spinnercontrol manualcontroller evasion
--@ gettargetpositioninfo terraincheck
-- Hover module
AltitudePID = PID.create(AltitudePIDConfig, CanReverseBlades and -30 or 0, 30)

LiftSpinners = SpinnerControl.create(Vector3.up, false, true, DediBladesAlwaysUp)

DesiredAltitude = 0

ManualAltitudeController = ManualController.create(ManualAltitudeDriveMaintainerFacing)
HalfMaxManualAltitude = MaxManualAltitude / 2

function Hover_Control(I)
   if ManualAltitudeDriveMaintainerFacing and ManualAltitudeWhen[I.AIMode] then
      DesiredAltitude = HalfMaxManualAltitude + ManualAltitudeController:GetReading(I) * HalfMaxManualAltitude
   else
      if GetTargetPositionInfo(I) then
         DesiredAltitude = CalculateEvasion(Evasion, DesiredAltitudeCombat)
      else
         DesiredAltitude = DesiredAltitudeIdle
      end
   end

   if not AbsoluteAltitude then
      -- Look ahead at the terrain, but don't fly lower than sea level
      local Velocity = I:GetVelocityVector()
      local Height = GetTerrainHeight(I, Velocity, 0, MaxAltitude)
      DesiredAltitude = DesiredAltitude + Height
   end
end

function Hover_Update(I)
   local CV = AltitudePID:Control(DesiredAltitude - Altitude)
   LiftSpinners:Classify(I)
   LiftSpinners:SetSpeed(I, CV)
end
