LookupTable = {}

function LookupTable.create(XMin, XMax, YMin, YMax, Size, DataPoints)
   -- Make shallow copy of data
   local DP = { unpack(DataPoints) }
   -- And sort it by X value
   table.sort(DP, function (a,b) return a[1] < b[1] end)
   -- Add proper boundaries so we don't have to deal with the edges
   if DP[1][1] > XMin then
      table.insert(DP, 1, { XMin, YMin })
   end
   if DP[#DP][1] < XMax then
      table.insert(DP, { XMax, YMax })
   end
   -- Now build lookup table
   local LT = {}
   for x = XMin,XMax,((XMax - XMin) / Size) do
      -- Find closest data point >= x
      local i = 0
      repeat
         i = i + 1
      until DP[i][1] >= x
      if x == DP[i][1] then
         -- Serendipitous!
         table.insert(LT, { unpack(DP[i]) })
      else
         -- Interpolate between this and previous
         local x0,y0 = unpack(DP[i-1])
         local x1,y1 = unpack(DP[i])
         table.insert(LT, { x, y0+(x-x0)*(y1-y0)/(x1-x0) })
      end
   end

   local self = {}
   self.XMin = XMin
   self.XMax = XMax
   self.Step = (XMax - XMin) / Size
   self.YMin = YMin
   self.YMax = YMax
   self.Table = LT
   self.Lookup = LookupTable.Lookup
   return self
end

function LookupTable:Lookup(x)
   -- Boundary check
   if x < self.XMin then
      return self.YMin
   elseif x > self.XMax then
      return self.YMax
   end

   -- Figure out (zero-based) index into lookup table
   local i = 1+math.floor((x - self.XMin) / self.Step)
   local x0,y0 = unpack(self.Table[i])
   if x == x0 or i == #self.Table then
      -- Exact match or end of table
      return y0
   else
      -- Interpolate
      local x1,y1 = unpack(self.Table[i+1])
      return y0+(x-x0)*(y1-y0)/(x1-x0)
   end
end
