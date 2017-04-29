-- http://lua-users.org/wiki/SimpleRound
function round(num, idp)
   local mult = 10^(idp or 0)
   return math.floor(num * mult + 0.5) / mult
end

function Update(I)
   local ToGlobal = Quaternion.LookRotation(I:GetConstructForwardVector(), I:GetConstructUpVector())
   local ToLocal = Quaternion.Inverse(ToGlobal)
   for i = 0,I:GetNumberOfMainframes()-1 do
      local Position = I:GetAiPosition(i) - I:GetConstructCenterOfMass()
      local LocalPosition = ToLocal * Position
      LocalPosition.x = round(LocalPosition.x)
      LocalPosition.y = round(LocalPosition.y)
      LocalPosition.z = round(LocalPosition.z)
      I:LogToHud(string.format("Mainframe #%d: %s", i, LocalPosition))
      -- Though promising, it isn't actually stable due to rounding.
      -- Maybe addressing mainframes through their offsets and
      -- accepting anything within 1 block would work?
   end
end
