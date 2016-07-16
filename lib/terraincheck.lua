--@ getselfinfo firstrun
-- Terrain following module
TerrainCheckPoints = {}
TerrainCheckForwardOffset = 0
TerrainCheckRearOffset = 0

-- Pre-calculate check points for terrain following
function TerrainCheck_FirstRun(I)
   local MaxDim = I:GetConstructMaxDimensions()
   local MinDim = I:GetConstructMinDimensions()
   local Dimensions = MaxDim - MinDim
   local HalfDimensions = Dimensions / 2

   TerrainCheckPoints[1] = 0
   TerrainCheckPoints[2] = -HalfDimensions.x
   TerrainCheckPoints[3] = HalfDimensions.x
   if TerrainCheckSubdivisions > 0 then
      local Delta = HalfDimensions.x / (TerrainCheckSubdivisions+1)
      for i=1,TerrainCheckSubdivisions do
         local x = i * Delta
         table.insert(TerrainCheckPoints, -x)
         table.insert(TerrainCheckPoints, x)
      end
   end

   TerrainCheckForwardOffset = MaxDim.z
   TerrainCheckRearOffset = MinDim.z
end
AddFirstRun(TerrainCheck_FirstRun)

-- Using pre-calculated check points, scan ahead a certain distance
-- (using Velocity * look-ahead time) and return maximum height of terrain.
function GetTerrainHeight(I, Velocity)
   -- Start with point under CoM
   local Height = I:GetTerrainAltitudeForPosition(CoM)
   local Speed = Velocity.magnitude
   local Direction = Velocity / Speed
   local Perp = Vector3.Cross(Direction, Vector3.up)

   -- Calculate (mid-point) distances for this velocity once
   local Distances = {}
   for _,t in pairs(TerrainCheckLookAhead) do
      table.insert(Distances, Position + Direction * (TerrainCheckForwardOffset + Speed * t))
   end

   -- Add the forward and rear of the vehicle
   table.insert(Distances, Position + Direction * TerrainCheckForwardOffset)
   table.insert(Distances, Position + Direction * TerrainCheckRearOffset)

   for i,Offset in pairs(TerrainCheckPoints) do
      local Side = Perp * Offset
      for _,Distance in pairs(Distances) do
         local TestPoint = Distance + Side
         Height = math.max(Height, I:GetTerrainAltitudeForPosition(TestPoint))
      end
   end

   return Height
end
