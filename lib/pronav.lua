-- Proportional navigation implementation
function ProNav(Gain, TimeStep, MissilePosition, MissileVelocity, TargetPosition, TargetVelocity)
   local Offset = TargetPosition - MissilePosition
   local RelativeVelocity = TargetVelocity - MissileVelocity
   local Omega = Vector3.Cross(Offset, RelativeVelocity) / Vector3.Dot(Offset, Offset)
   -- Acceleration will be orthogonal to missile velocity
   local Direction = MissileVelocity.normalized
   local Acceleration = Vector3.Cross(Direction * -Gain * RelativeVelocity.magnitude, Omega)

   -- Transform acceleration into a relative aim point
   return MissilePosition + MissileVelocity * TimeStep + Acceleration * TimeStep * TimeStep * 0.5
end
