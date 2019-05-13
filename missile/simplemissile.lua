--@ multiprofilecommon generalmissile
-- Multi profile module (simplemissile)
SimpleMissile = {}

function SimpleMissile_TopAttack(Config)
   local GMConfig = {
      Velocity = Config.Velocity,
      TurnRate = Config.TurnRate,

      MinAltitude = 0,
      DetonationRange = nil,
      DetonationAngle = 30,
      LookAheadTime = 2,
      LookAheadResolution = 3,

      AirProfileElevation = Config.AirElevation,
      AntiAir = {
         Phases = {
            {
               Change = { Thrust = Config.AntiAirThrust, },
            },
         },
      },

      Phases = {
         {
            Distance = function (MinTerminal) return MinTerminal(Config.AscentAltitude) end,
            Change = { When = { Angle = Config.TerminalAngle, }, Thrust = Config.TerminalThrust, },
         },
         {
            Distance = function (MinTerminal) return MinTerminal(Config.AscentAltitude) * Config.CruiseDistanceMultiplier end,
            AboveSeaLevel = true,
            MinElevation = 3,
            Altitude = 0,
            RelativeTo = 4,
            Change = { Thrust = Config.CruiseThrust, },
         },
         {
            Distance = 50,
            AboveSeaLevel = true,
            MinElevation = 3,
            Altitude = Config.AscentAltitude,
            RelativeTo = 0,
            Change = { Thrust = Config.AscentThrust, },
         },
      },
   }
   return GMConfig
end

function SimpleMissile_Torpedo(Config)
   local GMConfig = {
      Velocity = Config.Velocity,
      TurnRate = Config.TurnRate,

      MinAltitude = -500,
      DetonationRange = nil,
      DetonationAngle = 30,
      LookAheadTime = 2,
      LookAheadResolution = 3,

      Phases = {
         {
            Distance = function (MinTerminal) return MinTerminal(Config.RelativeDepth) end,
            Altitude = 0,
            RelativeTo = 6,
         },
         {
            Distance = 50,
            AboveSeaLevel = false,
            MinElevation = 10,
            Altitude = -Config.RelativeDepth,
            RelativeTo = 2,
         },
      },
   }
   return GMConfig  
end

function SimpleMissile.new(Config)
   local GMConfig
   if Config.RelativeDepth then
      GMConfig = SimpleMissile_Torpedo(Config)
   else
      GMConfig = SimpleMissile_TopAttack(Config)
   end

   return GeneralMissile.new(GMConfig)
end

MultiProfile_Init(SimpleMissile)
