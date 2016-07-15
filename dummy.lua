-- Just some dummy declarations to make it easy to run assembled scripts through
-- a Lua interpreter (out of game, for syntax checking).
Vector3 = {}

setmetatable(Vector3, Vector3)

function Vector3.__call(func, ...)
end

Vector3.back = nil
Vector3.down = nil
Vector3.forward = nil
Vector3.left = nil
Vector3.right = nil
Vector3.up = nil
