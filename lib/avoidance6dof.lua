--@ commons avoidancevectors
-- Avoidance module (position version)
-- Modifies position to avoid any friendlies & terrain
function Avoidance(I, Position, Relative)
   local Avoid = AvoidanceVectors(I)

   if not Avoid then
      return Position
   else
      -- Current position (as offset)
      local NewPosition = Position
      if not Relative then NewPosition = NewPosition - C:CoM() end
      -- Preserve vector length
      local Length = NewPosition.magnitude
      -- Now as unit vector
      NewPosition = NewPosition / Length
      -- Add avoidance vectors, re-scale
      NewPosition = (NewPosition + Avoid).normalized * Length
      if not Relative then NewPosition = NewPosition + C:CoM() end
      return NewPosition
   end
end
