-- Returns sign of the argument.
-- By default, returns 0 for 0, unlike Mathf.Sign which returns 1
function Sign(n, ZeroSign)
   if n > 0 then
      return 1
   elseif n < 0 then
      return -1
   else
      return ZeroSign or 0
   end
end
