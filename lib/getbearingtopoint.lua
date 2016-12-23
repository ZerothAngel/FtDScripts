--@ commons getvectorangle
-- Get bearing toward a given world point
function GetBearingToPoint(Point)
   local Offset = Point - C:CoM()
   return Mathf.DeltaAngle(C:Yaw(), GetVectorAngle(Offset))
end
