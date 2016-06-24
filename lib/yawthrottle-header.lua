-- Yaw PID controller settings
-- These default values have worked well for me on
-- a variety of ships. YMMV.
-- { 1.0, 0, 0 } is a good (but rough) starting point.
YawPIDValues = { 0.25, 0.0, 0.1 } -- P, I, D

-- To use forward (or reverse!) spinners as propulsion,
-- set either or both of the following options to true.
UseSpinners = false
UseDediSpinners = false
