--@ getselfinfo getvectorangle
-- Get bearing toward a given world point
function GetBearingToPoint(Point)
   local Offset = Point - CoM
   return Mathf.DeltaAngle(Yaw, GetVectorAngle(Offset))
end
