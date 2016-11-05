--@ firstrun
PerlinOffset = 0

function Evasion_FirstRun(_)
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(Evasion_FirstRun)

function CalculateEvasion(Evasion, Value)
   -- Modify by Evasion, if set
   if Evasion then
      return Value + Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * Now, PerlinOffset) - 1.0)
   else
      return Value
   end
end
