-- Returns the angle of a vector on the XZ plane relative to forward.
-- Slightly different than Vector3.Angle as it accounts for negative
-- (counter-clockwise) angles as well
function GetVectorAngle(v)
   return math.deg(math.atan2(v.x, v.z))
end
