--@ multiprofilecommon generalmissile
-- Multi profile module (simplemissile)
SimpleMissile = {}

function SimpleMissile_TurnRadius(Velocity, TurnRate)
   return Velocity / math.rad(TurnRate)
end

function SimpleMissile_MinTerminal(TurnRadius, AltitudeDelta)
   if TurnRadius <= AltitudeDelta then
      -- Simply the turn radius. Round up to nearest 25.
      return 25 * math.ceil(TurnRadius / 25)
   else
      -- Calculate and round up to nearest 25.
      local MinTerminal = math.sqrt(AltitudeDelta * (2 * TurnRadius - AltitudeDelta))
      return 25 * math.ceil(MinTerminal / 25)
   end
end

function SimpleMissile_TopAttack(Config)
   local TurnRadius = SimpleMissile_TurnRadius(Config.Velocity, Config.TurnRate)
   local MinTerminal = SimpleMissile_MinTerminal(TurnRadius, Config.AscentAltitude)
   local GMConfig = {
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
            Distance = MinTerminal,
            Change = { When = { Angle = Config.TerminalAngle, }, Thrust = Config.TerminalThrust, },
         },
         {
            Distance = MinTerminal * Config.CruiseDistanceMultiplier,
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
   local TurnRadius = SimpleMissile_TurnRadius(Config.Velocity, Config.TurnRate)
   local GMConfig = {
      MinAltitude = -500,
      DetonationRange = nil,
      DetonationAngle = 30,
      LookAheadTime = 2,
      LookAheadResolution = 3,

      Phases = {
         {
            Distance = SimpleMissile_MinTerminal(TurnRadius, Config.RelativeDepth),
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
