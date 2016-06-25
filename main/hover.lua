--! hover
--@ commons getvectorangle gettarget pid spinnercontrol
-- Hover module
AltitudePID = PID.create(AltitudePIDValues[1], AltitudePIDValues[2], AltitudePIDValues[3], CanReverseBlades and -30 or 0, 30)

FirstRun = nil
PerlinOffset = 0

CheckPoints = {}

LiftSpinners = SpinnerControl.create(Vector3.up, false, true)

function FirstRun(I)
   FirstRun = nil

   PerlinOffset = 1000.0 * math.random()

   -- Same idea as avoidance module. Origin is current position.
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2
   CheckPoints[1] = Vector3(0, 0, MaxDim.z)
   CheckPoints[2] = Vector3(-HalfDimensions.x, 0, MaxDim.z)
   CheckPoints[3] = Vector3(HalfDimensions.x, 0, MaxDim.z)
   if TerrainCheckSubdivisions > 0 then
      local Delta = HalfDimensions.x / (TerrainCheckSubdivisions+1)
      for i=1,TerrainCheckSubdivisions do
         local x = i * Delta
         CheckPoints[#CheckPoints+1] = Vector3(-x, 0, MaxDim.z)
         CheckPoints[#CheckPoints+1] = Vector3(x, 0, MaxDim.z)
      end
   end
end

function GetTerrainHeight(I, Angle, Speed)
   local Height = -500 -- Smallest altitude in the game
   local Rotation = Quaternion.Euler(0, Angle, 0) -- NB Angle is world
   for i,Start in pairs(CheckPoints) do
      for j,t in pairs(AltitudeLookAhead) do
         local Point = Start + Vector3.forward * Speed * t
         -- TODO Someday take Y-axis velocity into account as well
         Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Rotation * Point))
      end
   end
   return Height
end

function Update(I)
   local __func__ = "Update"

   if FirstRun then FirstRun(I) end

   LiftSpinners:Classify(I)

   if I.AIMode ~= "off" then
      GetSelfInfo(I)

      local DesiredAltitude
      if GetTarget(I) then
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
