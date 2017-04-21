-- Returns sign of the argument.
-- By default, returns 0 for 0, unlike Mathf.Sign which returns 1
function Sign(n, ZeroSign, Eps)
   Eps = Eps or 0
   if n > Eps then
      return 1
   elseif n < -Eps then
      return -1
   else
      return ZeroSign or 0
   end
end
