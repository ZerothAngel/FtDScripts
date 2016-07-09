--! hover
--@ terraincheck commons getvectorangle gettargetpositioninfo pid spinnercontrol
-- Hover module
AltitudePID = PID.create(AltitudePIDValues[1], AltitudePIDValues[2], AltitudePIDValues[3], CanReverseBlades and -30 or 0, 30)

FirstRun = nil
PerlinOffset = 0

LiftSpinners = SpinnerControl.create(Vector3.up, false, true)

function FirstRun(I)
   FirstRun = nil

   PerlinOffset = 1000.0 * math.random()

   TerrainCheckFirstRun(I)
end

function Update(I)
   local __func__ = "Update"

   if FirstRun then FirstRun(I) end

   -- Do this here to avoid classifying spinners if docked
   if I:IsDocked() then return end

   LiftSpinners:Classify(I)

   if I.AIMode ~= "off" then
      GetSelfInfo(I)

      local DesiredAltitude
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
         -- First check CoM's height
         local Height = I:GetTerrainAltitudeForPosition(CoM)
         -- Now check look-ahead values
         local Velocity = I:GetVelocityVector()
         Velocity.y = 0
         local Speed = Velocity.magnitude
         local VelocityAngle = GetVectorAngle(Velocity)
         Height = math.max(Height, GetTerrainHeight(I, VelocityAngle, Speed))
         -- Finally, don't fly lower than sea level
         Height = math.max(Height, 0)
         DesiredAltitude = DesiredAltitude + Height
      end

      local CV = AltitudePID:Control(DesiredAltitude - Altitude)

      if Debugging then Debug(I, __func__, "Altitude %f CV %f", Altitude, CV) end

      LiftSpinners:SetSpeed(I, CV)
   else
      -- If AI is off, turn all lift spinners off
      LiftSpinners:SetSpeed(I, 0)
   end
end
