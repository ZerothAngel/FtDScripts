-- Quartic solver
-- More or less a Lua translation of
-- https://github.com/erich666/GraphicsGems/blob/master/gems/Roots3And4.c by a Lua amateur, i.e. me
Roots3And4 = {
   Epsilon = 1e-9,
}

function Roots3And4.IsZero(x)
   return math.abs(x) < Roots3And4.Epsilon
end

function Roots3And4.CubeRoot(x)
   if x > 0 then
      return x^(1/3)
   elseif x < 0 then
      return -x^(1/3)
   else
      return 0
   end
end

function Roots3And4.SolveQuadric(c)
   -- normal form: x^2 + px + q = 0
   local p = c[2] / (2 * c[3])
   local q = c[1] / c[3]

   local D = p * p - q

   if Roots3And4.IsZero(D) then
      return { -p }
   elseif D < 0 then
      return {}
   else -- if (D > 0)
      local sqrt_D = math.sqrt(D)

      return { sqrt_D - p, -sqrt_D - p }
   end
end

function Roots3And4.SolveCubic(c)
   local s

   -- normal form: x^3 + Ax^2 + Bx + C = 0
   local A = c[3] / c[4]
   local B = c[2] / c[4]
   local C = c[1] / c[4]

   -- substitute x = y - A/3 to eliminate quadric term:
   -- x^3 +px + q = 0
   local sq_A = A * A
   local p = 1/3 * (-1/3 * sq_A + B)
   local q = 1/2 * (2/27 * A * sq_A - 1/3 * A * B + C)

   -- use Cardano's formula
   local cb_p = p * p * p
   local D = q * q + cb_p

   if Roots3And4.IsZero(D) then
      if Roots3And4.IsZero(q) then -- one triple solution
         return { 0 }
      else --one single and one double solution
         local u = Roots3And4.CubeRoot(-q)
         s = { 2 * u, -u }
      end
   elseif D < 0 then -- Casus irreducibilis: three real solutions
      local phi = 1/3 * math.acos(-q / math.sqrt(-cb_p))
      local t = 2 * math.sqrt(-p)

      s = { t * math.cos(phi),
               -t * math.cos(phi + math.pi / 3),
               -t * math.cos(phi - math.pi / 3) }
   else -- one real solution
      local sqrt_D = math.sqrt(D)
      local u = Roots3And4.CubeRoot(sqrt_D - q)
      local v = -Roots3And4.CubeRoot(sqrt_D + q)

      s = { u + v }
   end

   -- resubstitute
   local sub = 1/3 * A

   for i=1,#s do
      s[i] = s[i] - sub
   end

   return s
end

function Roots3And4.SolveQuartic(c)
   local s

   -- normal form: x^4 + Ax^3 + Bx^2 + Cx + D = 0
   local A = c[4] / c[5]
   local B = c[3] / c[5]
   local C = c[2] / c[5]
   local D = c[1] / c[5]

   -- substitute x = y - A/4 to eliminate cubic term:
   -- x^4 + px^2 + qx + r = 0
   local sq_A = A * A
   local p = -3/8 * sq_A + B
   local q = 1/8 * sq_A * A - 1/2 * A * B + C
   local r = -3/256*sq_A*sq_A + 1/16*sq_A*B - 1/4*A*C + D

    if Roots3And4.IsZero(r) then
       -- no absolute term: y(y^3 + py + q) = 0
       local coeffs = { q, p, 0, 1 }

       s = Roots3And4.SolveCubic(coeffs)

       table.insert(s, 0)
    else
       -- solve the resolvent cubic ...
       local coeffs = {
          1/2 * r * p - 1/8 * q * q, -r, -1/2 * p, 1
       }

       s = Roots3And4.SolveCubic(coeffs)

       -- ... and take the one real solution ...
       local z = s[1]

       -- ... to build two quadric equations

       local u = z * z - r
       local v = 2 * z - p

       if Roots3And4.IsZero(u) then
          u = 0
       elseif u > 0 then
          u = math.sqrt(u)
       else
          return {}
       end

       if Roots3And4.IsZero(v) then
          v = 0
       elseif v > 0 then
          v = math.sqrt(v)
       else
          return {}
       end

       coeffs = { z - u, q < 0 and -v or v, 1 }

       s = Roots3And4.SolveQuadric(coeffs)

       coeffs = { z + u, q < 0 and v or -v, 1 }

       local s2 = Roots3And4.SolveQuadric(coeffs)

       for i=1,#s2 do
          table.insert(s, s2[i])
       end
    end

    -- resubstitute
    local sub = 1/4 * A

    for i=1,#s do
       s[i] = s[i] - sub
    end

    return s
end

-- Conform to QuadradicSolver's interface
function QuarticSolver(a, b, c, d, e)
   return Roots3And4.SolveQuartic({ e, d, c, b, a })
end
