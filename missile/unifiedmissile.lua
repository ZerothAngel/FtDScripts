--@ generalmissile
-- UnifiedMissile implementation
UnifiedMissile = {}

function UnifiedMissile.create(Config)
   local GMConfig = {
      AirProfileElevation = Config.SpecialAttackElevation,
      MinAltitude = Config.MinimumAltitude,
      DetonationRange = Config.DetonationRange,
      DetonationAngle = Config.DetonationAngle,
      LookAheadTime = Config.LookAheadTime,
      LookAheadResolution = Config.LookAheadResolution,

      AntiAir = {
         Phases = {
            {
               Change = {
                  Thrust = Config.DefaultThrust,
               },
            },
         }
      },

      Phases = {
         {
            Distance = Config.TerminalDistance,
            Change = {
               When = { Angle = Config.TerminalThrustAngle, },
               Thrust = Config.TerminalThrust,
            },
         },
         {
            Distance = Config.ClosingDistance,
            AboveSeaLevel = Config.ClosingAboveSeaLevel,
            MinElevation = Config.ClosingElevation,
            Altitude = Config.ClosingAltitude,
            RelativeTo = Config.ClosingAltitudeRelativeTo,
            Change = {
               When = { Angle = Config.ClosingThrustAngle, },
               Thrust = Config.ClosingThrust,
            },
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
         Change = {
            When = { Angle = Config.SpecialManeuverThrustAngle, },
            Thrust = Config.SpecialManeuverThrust,
         },
      }
      table.insert(GMConfig.Phases, 2, SpecialManeuverPhase)
   end

   return GeneralMissile.create(GMConfig)
end
