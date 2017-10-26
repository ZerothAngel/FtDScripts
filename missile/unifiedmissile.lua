--@ generalmissile
-- UnifiedMissile implementation
UnifiedMissile = {}

function UnifiedMissile.new(Config)
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

   if Config.MiddleDistance then
      local MiddlePhase = {
         Distance = Config.MiddleDistance,
         AboveSeaLevel = Config.MiddleAboveSeaLevel,
         MinElevation = Config.MiddleElevation,
         Altitude = Config.MiddleAltitude,
         RelativeTo = Config.MiddleAltitudeRelativeTo,
         Change = {
            When = { Angle = Config.MiddleThrustAngle, },
            Thrust = Config.MiddleThrust,
         },
      }
      table.insert(GMConfig.Phases, 2, MiddlePhase)
   end

   return GeneralMissile.new(GMConfig)
end
