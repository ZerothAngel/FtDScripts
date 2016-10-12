--@ quadraticsolver
-- Calculates earliest intersection point between a ray and a sphere
-- centered at origin.
function RaySphereIntersect(Position, Velocity, RadiusSquared)
   local a = Vector3.Dot(Velocity, Velocity)
   local b = 2 * Vector3.Dot(Velocity, Position)
   local c = Vector3.Dot(Position, Position) - RadiusSquared
   local Solutions = QuadraticSolver(a, b, c)
   local ImpactTime = nil
   if #Solutions == 1 then
      local t = Solutions[1]
      if t > 0 then ImpactTime = t end
   elseif #Solutions == 2 then
      local t1 = Solutions[1]
      local t2 = Solutions[2]
      if t1 > 0 then
         ImpactTime = t1
      elseif t2 > 0 then
         ImpactTime = t2
      end
   end

   if ImpactTime then
      local ImpactPoint = Position + Velocity * ImpactTime
      return ImpactPoint, ImpactTime
   else
      return nil
   end
end
