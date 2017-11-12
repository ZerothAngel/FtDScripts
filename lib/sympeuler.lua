function sympeuler_simulate(Initial, Start, End, dt, Acceleration)
   local State = { x = Initial.x, v = Initial.v }

   local t = Start
   while t < End do
      State.v = State.v + Acceleration(State, t + dt) * dt
      State.x = State.x + State.v * dt
      t = t + dt
   end

   return State
end
