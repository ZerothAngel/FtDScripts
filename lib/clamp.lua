-- Clamps a value between minimum and maximum, inclusive.
--# My own implementation to avoid calling into Mathf
function Clamp(n, Min, Max)
   --# Try explicit if/else rather than using math.min/max.
   --# Ironic, the idented version probably uses more bytes than we save...
   if n < Min then return Min elseif n > Max then return Max else return n end
end
