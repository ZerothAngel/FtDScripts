--@ commons firstrun
PerlinOffset = 0

function Evasion_FirstRun(_)
   -- Used as Y coordinate for Perlin generator
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(Evasion_FirstRun)

-- Offset by Evasion, if set
function CalculateEvasion(Evasion)
   if Evasion then
      return Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * C:Now(), PerlinOffset) - 1.0)
   else
      return 0
   end
end
