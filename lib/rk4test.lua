require('rk4')

function g(State, t)
   return -9.8
end

function sim(Runtime, Step)
   Step = Step or .025
   local Final = rk4_simulate({ x = 0, v = 20 }, 0, Runtime, Step, g)
   print(string.format("Final: x = %.02f, v = %.02f", Final.x, Final.v))
end
