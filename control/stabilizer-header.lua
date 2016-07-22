-- ROLL/PITCH STABILIZATION

-- PID values for stabilization using propulsion elements.
-- Start with { 1, 0, 0 } and tune from there.
RollPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}
PitchPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}
