-- https://gafferongames.com/post/integration_basics/
function rk4_evaluate(Initial, t, dt, d, Acceleration)
   local State = {
      x = Initial.x + d.dx * dt,
      v = Initial.v + d.dv * dt,
   }
   local Output = {
      dx = State.v,
      dv = Acceleration(State, t + dt),
   }
   return Output
end

function rk4_integrate(State, t, dt, Acceleration, Zero)
   local a = rk4_evaluate(State, t, 0, { dx = Zero, dv = Zero, }, Acceleration)
   local b = rk4_evaluate(State, t, dt * 0.5, a, Acceleration)
   local c = rk4_evaluate(State, t, dt * 0.5, b, Acceleration)
   local d = rk4_evaluate(State, t, dt, c, Acceleration)

   local dxdt = (1/6) * (a.dx + 2 * (b.dx + c.dx) + d.dx)
   local dvdt = (1/6) * (a.dv + 2 * (b.dv + c.dv) + d.dv)

   State.x = State.x + dxdt * dt
   State.v = State.v + dvdt * dt
end

function rk4_simulate(Initial, Start, End, dt, Acceleration, Zero)
   Zero = Zero or 0

   local State = { x = Initial.x, v = Initial.v }

   local t = Start
   while t < End do
      rk4_integrate(State, t, dt, Acceleration, Zero)
      t = t + dt
   end

   return State
end
