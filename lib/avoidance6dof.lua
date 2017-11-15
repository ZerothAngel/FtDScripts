--@ commons avoidancevectors
-- Avoidance module (position version)
-- Modifies position to avoid any friendlies & terrain
function Avoidance(I, Position, Relative)
   local FCount, FAvoid, TCount, TAvoid = AvoidanceVectors(I)

   if (FCount + TCount) == 0 then
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
      NewPosition = (NewPosition + FAvoid + TAvoid) * Length
      if not Relative then NewPosition = NewPosition + C:CoM() end
      return NewPosition
   end
end
