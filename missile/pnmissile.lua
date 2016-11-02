--@ generalmissile
-- PN guided missile
ProNavMissile = {}

function ProNavMissile.create(Config)
   local GMConfig = {
      MinAltitude = Config.MinimumAltitude,
      DetonationRange = Config.DetonationRange,
      DetonationAngle = Config.DetonationAngle,
      LookAheadTime = nil,
      LookAheadResolution = 3,

      AntiAir = {
         DefaultThrust = Config.DefaultThrust,
         TerminalRange = Config.TerminalRange,
         Thrust = Config.TerminalThrust,
         ThrustAngle = Config.TerminalThrustAngle,
         OneTurnTime = Config.OneTurnTime,
         OneTurnAngle = Config.OneTurnAngle,
         Gain = Config.Gain,
      },
   }

   return GeneralMissile.create(GMConfig)
end
