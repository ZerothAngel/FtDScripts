--@ pid spinnercontrol firstrun
--@ gettargetpositioninfo terraincheck
-- Hover module
AltitudePID = PID.create(AltitudePIDConfig, CanReverseBlades and -30 or 0, 30)

PerlinOffset = 0

LiftSpinners = SpinnerControl.create(Vector3.up, false, true)

DesiredAltitude = 0

function Hover_FirstRun(I)
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(Hover_FirstRun)

function Hover_Control(I)
   if GetTargetPositionInfo(I) then
      DesiredAltitude = DesiredAltitudeCombat

      -- Modify by Evasion, if set
      if Evasion then
         DesiredAltitude = DesiredAltitude + Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * I:GetTimeSinceSpawn(), PerlinOffset) - 1.0)
      end
   else
      DesiredAltitude = DesiredAltitudeIdle
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
