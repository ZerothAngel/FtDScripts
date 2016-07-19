-- Returns sign of the argument.
-- Differs from Mathf.Sign in that it returns 0 for 0
function Sign(n)
   if n > 0 then
      return 1
   elseif n < 0 then
      return -1
   else
      return 0
   end
end
