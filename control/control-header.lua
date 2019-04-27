-- GENERAL VEHICLE CONTROL SETTINGS

VehicleConfig = {
   -- Minimum speed in meters per second.
   -- Probably not a good idea for airplanes or hydrofoil-based subs to stop.
   -- If nil, it will use the script's default, which is 0 in most cases.
   MinimumSpeed = nil,
   -- Constants for throttle PID, used when trying to move at a specific speed.
   ThrottlePIDConfig = {
      Kp = .01,
      Ti = 0,
      Td = .125,
   },
}
