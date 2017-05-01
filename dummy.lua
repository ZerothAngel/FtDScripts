-- Just some dummy declarations to make it easy to run assembled scripts through
-- a Lua interpreter (out of game, for syntax checking).
Vector3 = {}

setmetatable(Vector3, Vector3)

function Vector3.__call(func, x, y, z)
   local self = {}
   self.x = x
   self.y = y
   self.z = z
   setmetatable(self, Vector3)
   return self
end

function Vector3.__unm(op)
   return Vector3(-op.x, -op.y, -op.z)
end

function Vector3.Cross(a, b)
   return Vector3(0, 0, 0) -- Meh
end

Vector3.zero = Vector3(0, 0, 0)
Vector3.back = Vector3(0, 0, -1)
Vector3.down = Vector3(0, -1, 0)
Vector3.forward = Vector3(0, 0, 1)
Vector3.left = Vector3(-1, 0, 0)
Vector3.right = Vector3(1, 0, 0)
Vector3.up = Vector3(0, 1, 0)
