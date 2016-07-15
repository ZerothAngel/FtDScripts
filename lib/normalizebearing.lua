-- Normalizes a bearing to (-180, 180].
function NormalizeBearing(Bearing)
   Bearing = Bearing % 360
   if Bearing > 180 then Bearing = Bearing - 360 end
   return Bearing
end
