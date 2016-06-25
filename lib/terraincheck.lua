-- Terrain following module
TerrainCheckPoints = {}

-- Pre-calculate check points for terrain following
function TerrainCheckFirstRun(I)
   -- Same idea as avoidance module. Origin is current position.
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2
   TerrainCheckPoints[1] = Vector3(0, 0, MaxDim.z)
   TerrainCheckPoints[2] = Vector3(-HalfDimensions.x, 0, MaxDim.z)
   TerrainCheckPoints[3] = Vector3(HalfDimensions.x, 0, MaxDim.z)
   if TerrainCheckSubdivisions > 0 then
      local Delta = HalfDimensions.x / (TerrainCheckSubdivisions+1)
      for i=1,TerrainCheckSubdivisions do
         local x = i * Delta
         TerrainCheckPoints[#TerrainCheckPoints+1] = Vector3(-x, 0, MaxDim.z)
         TerrainCheckPoints[#TerrainCheckPoints+1] = Vector3(x, 0, MaxDim.z)
      end
   end
end

-- Using pre-calculated check points, scan ahead at the given angle
-- (using Speed * look-ahead time) and return maximum height of terrain.
function GetTerrainHeight(I, Angle, Speed)
   local Height = -500 -- Smallest altitude in the game
   local Rotation = Quaternion.Euler(0, Angle, 0) -- NB Angle is world
   for i,Start in pairs(TerrainCheckPoints) do
      for j,t in pairs(TerrainCheckLookAhead) do
         local Point = Start + Vector3.forward * Speed * t
         -- TODO Someday take Y-axis velocity into account as well
         Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Rotation * Point))
      end
   end
   return Height
end
