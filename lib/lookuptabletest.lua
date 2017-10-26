require("lookuptable")

DataPoints = {}
for i = 0,90,15 do
   table.insert(DataPoints, { i, math.sin(math.rad(i)) })
end

function dump(t)
   for _,v in ipairs(t) do
      print(unpack(v))
   end
end

LT6 = LookupTable.new(0, 90, 0, 1, 6, DataPoints)
LT9 = LookupTable.new(0, 90, 0, 1, 9, DataPoints)
LT18 = LookupTable.new(0, 90, 0, 1, 18, DataPoints)
