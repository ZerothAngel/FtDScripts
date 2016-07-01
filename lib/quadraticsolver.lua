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
      local twoA = 2 * a
      if disc < 0 then
         return {} -- Imaginary
      elseif disc == 0 then
         -- Single solution
         return { -b / twoA }
      else
         -- Two solutions
         local root = Mathf.Sqrt(disc)
         local t1 = (-b + root) / twoA
         local t2 = (-b - root) / twoA
         return { t1, t2 }
      end
   end
end
