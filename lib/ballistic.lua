--@ quarticsolver
-- Cannon assumed to be at origin
-- Gravity assumed to be inverted vector, i.e. pointing upwards.
function BallisticAimPoint(Speed, RelativePosition, RelativeVelocity, Gravity)
   -- https://playtechs.blogspot.com/2007/04/aiming-at-moving-target.html
   local a = Vector3.Dot(Gravity, Gravity) / 4
   local b = Vector3.Dot(RelativeVelocity, Gravity)
   local c = Vector3.Dot(RelativePosition, Gravity) + Vector3.Dot(RelativeVelocity, RelativeVelocity) - Speed * Speed
   local d = 2 * Vector3.Dot(RelativePosition, RelativeVelocity)
   local e = Vector3.Dot(RelativePosition, RelativePosition)
   local Solutions = QuarticSolver(a, b, c, d, e)
   local ImpactTime = math.huge
   -- Pick smallest positive impact time
   for _,s in pairs(Solutions) do
      if s > 0 and s < ImpactTime then
         ImpactTime = s
      end
   end
   if ImpactTime < math.huge then
      return RelativePosition + RelativeVelocity * ImpactTime + Gravity * .5 * ImpactTime * ImpactTime
   else
      return nil
   end
end
