-- AIRPLANE CONFIGURATION

-- Control fractions dedicated to spinners for each axis
-- Set to a positive value (usually 1) to use (dediblade)
-- spinners for the given axis.
SpinnerFractions = {
   -- Side-facing spinners
   Yaw = 0,
   -- Upward- and downward-facing spinners
   Pitch = 0,
   Roll = 0,
   -- Forward- and reverse-facing spinners
   Throttle = 0,
}

-- PID values
AltitudePIDConfig = {
   Kp = .1,
   Ti = 10,
   Td = .7,
}
YawPIDConfig = {
   Kp = .3,
   Ti = 10,
   Td = .7,
}
PitchPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}
RollPIDConfig = {
   Kp = .5,
   Ti = 5,
   Td = .1,
}

-- Pitch settings

-- Maximum pitch magnitude up & down. Can be up to, but NOT including 90.
-- Note that this is just the maximum pitch assuming the plane is flying
-- level. While rolling, the pitch limit is naturally increased because of
-- the math, which works out well for banked turns.
MaxPitch = 45

-- Roll settings

-- Bearing difference necessary for banked turn. Set to nil to disable.
AngleBeforeRoll = 10

-- Minimum altitude necessary for banked turn. Set to negative number
-- to perform a banked turn no matter what (as long as AngleBeforeRoll
-- condition was met).
MinAltitudeForRoll = 200

-- Maximum roll angle to perform during banked turn. 0-180 degrees.
MaxRollAngle = 50

-- To have the roll angle scale based on the magnitude of the bearing
-- difference, set the number here.
-- Calculated as: (roll angle) = (bearing difference - AngleBeforeRoll) *
--   RollAngleGain
-- If (roll angle) is greater than MaxRollAngle, MaxRollAngle will be
-- used instead.
-- To always use MaxAngleRoll, set RollAngleGain to nil.
RollAngleGain = 2
