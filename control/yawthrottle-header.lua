-- YAW & PROPULSION

-- Control fractions dedicated to spinners for each axis
-- Set to a positive value up to and including 1 to use (dediblade)
-- spinners for the given axis.
YawThrottleSpinnerFractions = {
   -- Side-facing spinners
   Yaw = 0,
   -- Forward- and reverse-facing spinners
   Throttle = 0,
}

-- Yaw PID controller settings
-- These default values have worked well for me on
-- a variety of ships. YMMV.
-- { 1, 0, 0 } is a good (but rough) starting point.
YawPIDConfig = {
   Kp = .25,
   Ti = 0,
   Td = .4,
}
