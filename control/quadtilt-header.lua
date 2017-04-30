-- QUAD TILT CONFIGURATION

-- This module only affects spinners whose "up" vectors line on the
-- X axis.

-- The vehicle is split into octants with the CoM in the center.
-- The follow holds one angle for each octant.
-- Left = -X, Right = +X, Lower = -Y, Upper = +Y, Rear = -Z, Forward = +Z
-- The octants, in order, are:
--   -X,-Y,-Z
--   +X,-Y,-Z
--   -X,+Y,-Z
--   +X,+Y,-Z
--   -X,-Y,+Z
--   +X,-Y,+Z
--   -X,+Y,+Z
--   +X,+Y,+Z
QuadTiltAngles = { 75, 75, 75, 75, 30, 30, 30, 30 }

QuadTiltRestAngle = 0
