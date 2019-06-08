--@ commons firstrun
-- Terrain following module
TerrainCheckPoints = {}
CurrentMaxVerticalSpeed = 1

-- Pre-calculate check points for terrain following
function TerrainCheck_FirstRun(I)
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2

   table.insert(TerrainCheckPoints, 0)
   table.insert(TerrainCheckPoints, -HalfDimensions.x)
   table.insert(TerrainCheckPoints, HalfDimensions.x)
   if TerrainCheckSubdivisions > 0 then
      local Delta = HalfDimensions.x / (TerrainCheckSubdivisions+1)
      for i=1,TerrainCheckSubdivisions do
         local x = i * Delta
         table.insert(TerrainCheckPoints, -x)
         table.insert(TerrainCheckPoints, x)
      end
   end

   if not TerrainCheckResolution then
      TerrainCheckResolution = HalfDimensions.z
   end
   if TerrainCheckMaxVerticalSpeed then
      CurrentMaxVerticalSpeed = TerrainCheckMaxVerticalSpeed
   end
end
AddFirstRun(TerrainCheck_FirstRun)

-- Using pre-calculated check points, scan ahead a certain distance
-- (using Velocity * look-ahead time) and return maximum height of terrain.
function GetTerrainHeight(I, Velocity, MinAltitude, MaxAltitude)
   local Height = MinAltitude
   local Speed = Velocity.magnitude
   local Direction = Velocity / Speed
   local Perp = Vector3.Cross(Direction, Vector3.up)

   -- Determine how far to look ahead
   local LookAheadTime
   if TerrainCheckLookAheadTime then
      LookAheadTime = TerrainCheckLookAheadTime
   else
      -- If using dynamic vertical speed, update that first.
      -- Note: Only care about positive vertical speeds.
      -- Don't count falling!
      if not TerrainCheckMaxVerticalSpeed and Velocity.y > CurrentMaxVerticalSpeed then
         CurrentMaxVerticalSpeed = Velocity.y
      end

      local RemainingAltitude = math.max(0, MaxAltitude - C:Altitude())
      LookAheadTime = math.max(1, TerrainCheckBufferFactor * RemainingAltitude / CurrentMaxVerticalSpeed)
   end

   local LookAhead = (MinAltitude < 0) and I.GetTerrainAltitudeLookingAhead or I.GetWaveOrTerrainAltitudeLookingAhead
   local MaxDistance = Velocity * LookAheadTime
   for _,Offset in pairs(TerrainCheckPoints) do
      local TestPoint = C:CoM() + Perp * Offset
      Height = math.max(Height, LookAhead(I, TestPoint, MaxDistance, TerrainCheckResolution))
   end

   return Height
end
