-- Returns solution(s) to a quadratic equation in table form.
-- Table will be empty if solutions are imaginary or invalid.
function QuadraticSolver(a, b, c)
   if a == 0 then
      -- Actually linear
      if b ~= 0 then
         return { -c / b }
      else
         return {} -- Division by zero...
      end
   else
      -- Discriminant
      local disc = b * b - 4 * a * c
      if disc < 0 then
         return {} -- Imaginary
      elseif disc == 0 then
         -- Single solution
         return { -.5 * b / a }
      else
         -- Two solutions
         local q = (b > 0) and (-.5 * (b + math.sqrt(disc))) or (-.5 * (b - math.sqrt(disc)))
         local t1 = q / a
         local t2 = c / q
         if t1 > t2 then
            return { t2, t1 }
         else
            return { t1, t2 }
         end
      end
   end
end
