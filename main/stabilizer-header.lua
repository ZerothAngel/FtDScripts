-- Switches to enable/disable control of each axis.
ControlRoll = true
ControlPitch = true

-- PID values for propulsion
-- Start with { 1, 0, 0 } and tune from there.
RollPIDConfig = {
   Kp = .1,
   Ti = 5,
   Td = .1,
}
PitchPIDConfig = {
   Kp = .1,
   Ti = 5,
   Td = .1,
}

-- If true then the thrust of propulsion closer to the Center of Mass
-- (on both X and Z axes) will be scaled up in proportion to the
-- distance of the furthest propulsion.
-- Note: Leave false, doesn't seem to work as well as it does with
-- hydrofoils.
ScaleByCoMOffset = false
