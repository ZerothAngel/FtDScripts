--@ generalmissile
-- UnifiedMissile implementation
UnifiedMissile = {}

function UnifiedMissile.create(Config)
   local GMConfig = {
      ProfileActivationElevation = Config.SpecialAttackElevation,
      MinAltitude = Config.MinimumAltitude,
      DetonationRange = Config.DetonationRange,
      DetonationAngle = Config.DetonationAngle,
      LookAheadTime = Config.LookAheadTime,
      LookAheadResolution = Config.LookAheadResolution,

      AntiAir = {
         DefaultThrust = Config.DefaultThrust,
         OneTurnTime = 3,
         OneTurnAngle = 15,
         Gain = 5,
      },

      Phases = {
         {
            Distance = Config.TerminalDistance,
            Thrust = Config.TerminalThrust,
            ThrustAngle = Config.TerminalThrustAngle,
         },
         {
            Distance = Config.ClosingDistance,
            AboveSeaLevel = Config.ClosingAboveSeaLevel,
            MinElevation = Config.ClosingElevation,
            Altitude = Config.ClosingAltitude,
            RelativeTo = Config.ClosingAltitudeRelativeTo,
            Thrust = Config.ClosingThrust,
            ThrustAngle = Config.ClosingThrustAngle,
            Evasion = Config.Evasion,
         },
      },
   }

   if Config.SpecialManeuverDistance then
      local SpecialManeuverPhase = {
         Distance = Config.SpecialManeuverDistance,
         AboveSeaLevel = Config.SpecialManeuverAboveSeaLevel,
         MinElevation = Config.SpecialManeuverElevation,
         Altitude = Config.SpecialManeuverAltitude,
         RelativeTo = Config.SpecialManeuverAltitudeRelativeTo,
         Thrust = Config.SpecialManeuverThrust,
         ThrustAngle = Config.SpecialManeuverThrustAngle,
      }
      table.insert(GMConfig.Phases, 2, SpecialManeuverPhase)
   end

   return GeneralMissile.create(GMConfig)
end
