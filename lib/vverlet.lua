function vverlet_simulate(Initial, Start, End, dt, Acceleration)
   local State = { x = Initial.x, v = Initial.v }

   local t,dv = Start,Acceleration(State, Start)
   while t < End do
      State.x = State.x + State.v * dt + dv * 0.5 * dt * dt
      local dvp1 = Acceleration(State, t + dt)
      State.v = State.v + (dv + dvp1) * 0.5 * dt
      dv = dvp1
      t = t + dt
   end

   return State
end

