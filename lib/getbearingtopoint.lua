-- Get bearing toward a given world point
function GetBearingToPoint(I, Point)
   return -I:GetTargetPositionInfoForPosition(0, Point.x, 0, Point.z).Azimuth
end
