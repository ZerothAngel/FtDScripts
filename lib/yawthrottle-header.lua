-- Yaw PID controller settings
-- These default values have worked well for me on
-- a variety of ships. YMMV.
-- { 1, 0, 0 } is a good (but rough) starting point.
YawPIDConfig = {
   Kp = 0.25,
   Ti = 0,
   Td = 0.4,
}

-- To use forward (or reverse!) spinners as propulsion,
-- set either or both of the following options to true.
UseSpinners = false
UseDediSpinners = false
