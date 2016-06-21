-- Returns the angle of a vector on the XZ plane relative to forward.
-- Slightly different than Vector3.Angle as it accounts for negative
-- (counter-clockwise) angles as well
function GetVectorAngle(v)
   -- Dot products with axis vectors
   local Xdot = Vector3.Dot(v, Vector3.right)
   local Zdot = Vector3.Dot(v, Vector3.forward)
   -- Now project
   local Xproj = Vector3.right * Xdot
   local Zproj = Vector3.forward * Zdot
   -- Now length of projections
   local x = Xproj.magnitude * Mathf.Sign(Xdot)
   local z = Zproj.magnitude * Mathf.Sign(Zdot)
   return Mathf.Atan2(x, z) * Mathf.Rad2Deg
end
