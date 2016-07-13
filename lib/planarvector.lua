-- Returns offset vector with target at same height as origin
function PlanarVector(Origin, Target)
   local NewTarget = Vector3(Target.x, Origin.y, Target.z)
   return NewTarget - Origin, NewTarget
end
