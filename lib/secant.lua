-- Secant method root finder
function Secant(f, x, Tolerance, MaxIter)
   if not Tolerance then Tolerance = 1e-8 end
   if not MaxIter then MaxIter = 10 end

   local x1,x0
   local fx1,fx0

   x0 = x + 4 * Tolerance

   fx0 = f(x0)

   local k = 0

   while k <= MaxIter and math.abs(x - x0) >= Tolerance do
      x1,x0,fx1 = x0,x,fx0
      fx0 = f(x0)
      x = x0 - fx0 * (x0 - x1) / (fx0 - fx1)
      k = k + 1
   end

   if k <= MaxIter then
      return x
   else
      return nil
   end
end
