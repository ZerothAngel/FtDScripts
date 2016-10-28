--@ quadraticintercept round
-- UnifiedMissile implementation
UnifiedMissile = {}

function UnifiedMissile.create(Config)
   local self = {}

   -- General parameters
   self.SpecialAttackElevation = Config.SpecialAttackElevation -- number
   self.MinimumAltitude = Config.MinimumAltitude -- number
   self.DefaultThrust = Config.DefaultThrust -- number or nil

   -- Proximity fuse parameters
   self.DetonationRange = Config.DetonationRange -- number
   self.DetonationAngle = math.cos(math.rad(Config.DetonationAngle or 0)) -- number

   -- Note: "RelativeTo" parameters should be one of
   -- 0 - Absolute
   -- 1 - Relative to target's altitude
   -- 2 - Relative to target's sea depth
   -- 3 - Relative to target's ground
   -- 4 - Relative to missile's altitude

   -- Closing parameters
   self.ClosingDistance = Config.ClosingDistance -- number
   self.ClosingAboveSeaLevel = Config.ClosingAboveSeaLevel -- bool
   self.ClosingElevation = Config.ClosingElevation -- number
   self.ClosingAltitude = Config.ClosingAltitude -- number or nil
   self.ClosingAltitudeRelativeTo = Config.ClosingAltitudeRelativeTo -- number
   self.ClosingThrust = Config.ClosingThrust -- number or nil
   self.ClosingThrustAngle = Config.ClosingThrustAngle and math.cos(math.rad(Config.ClosingThrustAngle)) or nil -- number or nil
   self.Evasion = Config.Evasion -- { number, number } or nil

   -- Special maneuver parameters
   self.SpecialManeuverDistance = Config.SpecialManeuverDistance -- number
   self.SpecialManeuverAboveSeaLevel = Config.SpecialManeuverAboveSeaLevel -- bool
   self.SpecialManeuverElevation = Config.SpecialManeuverElevation -- number
   self.SpecialManeuverAltitude = Config.SpecialManeuverAltitude -- number or nil
   self.SpecialManeuverAltitudeRelativeTo = Config.SpecialManeuverAltitudeRelativeTo -- number
   self.SpecialManeuverThrust = Config.SpecialManeuverThrust -- number or nil
   self.SpecialManeuverThrustAngle = Config.SpecialManeuverThrustAngle and math.cos(math.rad(Config.SpecialManeuverThrustAngle)) or nil -- number or nil

   -- Terminal parameters
   self.TerminalDistance = Config.TerminalDistance -- number
   self.TerminalThrust = Config.TerminalThrust -- number or nil
   self.TerminalThrustAngle = Config.TerminalThrustAngle and math.cos(math.rad(Config.TerminalThrustAngle)) or nil -- number or nil

   -- Terrain hugging parameters
   self.LookAheadTime = Config.LookAheadTime -- number
   self.LookAheadResolution = Config.LookAheadResolution -- number

   -- Methods (because no setmetatable)
   self.InitState = UnifiedMissile.InitState
   self.SetThrust = UnifiedMissile.SetThrust
   self.GetTerrainHeight = UnifiedMissile.GetTerrainHeight
   self.ModifyAltitude = UnifiedMissile.ModifyAltitude
   self.SpecialAttackAltitude = UnifiedMissile.SpecialAttackAltitude
   self.SpecialAttack = UnifiedMissile.SpecialAttack
   self.SetTarget = UnifiedMissile.SetTarget
   self.Guide = UnifiedMissile.Guide

   return self
end

-- Initialize state, save info about missile
function UnifiedMissile:InitState(I, TransceiverIndex, MissileIndex, MissileState)
   local Fuel = 0
   local ThrusterCount,Thrust = 0,0
   local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)
   for _,Part in pairs(MissileInfo.Parts) do
      if Part.Name == "missile fuel tank" then
         Fuel = Fuel + 5000
      elseif Part.Name == "missile variable speed thruster" then
         ThrusterCount = ThrusterCount + 1
         Thrust = Thrust + Part.Registers[2]
      end
   end
   MissileState.Fuel = Fuel
   MissileState.ThrusterCount = ThrusterCount
   MissileState.CurrentThrust = Thrust
end

-- Set thrust according to flavor
function UnifiedMissile:SetThrust(I, Position, Velocity, AimPoint, MissileState, Thrust, ThrustAngle, TransceiverIndex, MissileIndex)
   if not Thrust then return end
   local CurrentThrust = MissileState.CurrentThrust
   if not CurrentThrust or Thrust ~= CurrentThrust then
      if ThrustAngle then
         -- Note this is against predicted aim point, unlike the detonation check.
         local TargetVector = AimPoint - Position
         local CosAngle = Vector3.Dot(TargetVector.normalized, Velocity.normalized)
         if CosAngle < ThrustAngle then return end -- Not yet
      end
      -- Perform voodoo that is apparently deprecated and/or unstable
      -- But since all the cool kids are doing it...

      -- How do we check if this is valid?
      local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)

      local ThrusterCount = MissileState.ThrusterCount
      for _,Part in pairs(MissileInfo.Parts) do
         -- Is this name constant or localized?
         if Part.Name == "missile variable speed thruster" then
            -- Each thruster carries its share
            Part:SendRegister(2, Thrust / ThrusterCount)
         end
      end
      MissileState.CurrentThrust = Thrust
   end
end

-- Return highest terrain seen within look-ahead distance
function UnifiedMissile:GetTerrainHeight(I, Position, Velocity, MaxDistance)
   if not MaxDistance then MaxDistance = math.huge end

   local LookAheadResolution = self.LookAheadResolution
   if LookAheadResolution <= 0 then return -500 end

   local Height = -500
   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = PlanarVelocity.magnitude
   local Direction = PlanarVelocity / Speed

   local Distance = math.min(Speed * self.LookAheadTime, MaxDistance)

   for d = 0,Distance-1,LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return Height
end

-- Modify an altitude according to RelativeTo
function UnifiedMissile:ModifyAltitude(Position, Altitude, RelativeTo)
   if RelativeTo == 1 then
      -- Relative to target's absolute altitude [-500, whatever)
      return self.TargetAltitude + Altitude
   elseif RelativeTo == 2 then
      -- Relative to target's sea depth [-500, 0]
      return self.TargetDepth + Altitude
   elseif RelativeTo == 3 then
      -- Relative to target's ground [0, whatever)
      return self.TargetGround + Altitude
   elseif RelativeTo == 4 then
      -- Relative to missile's altitude
      return Position.y + Altitude
   else
      -- Absolute (no modification)
      return Altitude
   end
end

-- Modify altitude according to flavor
function UnifiedMissile:SpecialAttackAltitude(I, Position, Velocity, AboveSeaLevel, Elevation, Altitude, RelativeTo, MaxDistance)
   local Height = self:GetTerrainHeight(I, Position, Velocity, MaxDistance)
   if AboveSeaLevel then
      -- Constrain terrain hugging to sea level
      Height = math.max(Height, 0)
   end
   Height = Height + Elevation

   if not Altitude then
      -- Always relative to terrain.
      return Height
   else
      -- Relative to something, hugging terrain if necessary.
      return math.max(self:ModifyAltitude(Position, Altitude, RelativeTo), Height)
   end
end

-- Modification of the aim point to give the missile its flavor
function UnifiedMissile:SpecialAttack(I, Position, Velocity, AimPoint, Offset, MissileState, TransceiverIndex, MissileIndex, ImpactTime)
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   local TerminalDistance = self.TerminalDistance
   local SpecialManeuverDistance = self.SpecialManeuverDistance
   if GroundDistance < TerminalDistance then
      local Thrust = self.TerminalThrust
      if Thrust and Thrust < 0 then
         -- Base terminal thrust on current fuel and predicted impact time
         Thrust = Round(MissileState.Fuel / ImpactTime, 1)
         -- Constrain (is this needed?)
         Thrust = math.max(50, math.min(10000, Thrust))
      end
      self:SetThrust(I, Position, Velocity, AimPoint, MissileState, Thrust, self.TerminalThrustAngle, TransceiverIndex, MissileIndex)
      -- Always return real aim point when within terminal distance
      return AimPoint
   elseif SpecialManeuverDistance and GroundDistance < SpecialManeuverDistance then
      -- Begin special maneuver, if any. Generally a pop-up or pop-under.
      local GroundDirection = GroundOffset / GroundDistance
      local ToTerminal = GroundDistance - TerminalDistance

      -- New aim point is toward target at edge of terminal distance
      local NewAimPoint = Position + GroundDirection * ToTerminal
      NewAimPoint.y = self:SpecialAttackAltitude(I, Position, Velocity, self.SpecialManeuverAboveSeaLevel, self.SpecialManeuverElevation, self.SpecialManeuverAltitude, self.SpecialManeuverAltitudeRelativeTo, ToTerminal)

      self:SetThrust(I, Position, Velocity, AimPoint, MissileState, self.SpecialManeuverThrust, self.SpecialManeuverThrustAngle, TransceiverIndex, MissileIndex)
      return NewAimPoint
   else
      -- Closing
      local GroundDirection = GroundOffset / GroundDistance
      local NewAimPoint = Position + GroundDirection * self.ClosingDistance
      NewAimPoint.y = self:SpecialAttackAltitude(I, Position, Velocity, self.ClosingAboveSeaLevel, self.ClosingElevation, self.ClosingAltitude, self.ClosingAltitudeRelativeTo)

      -- Perform horizontal evasion, if any
      local Evasion = self.Evasion
      if Evasion then
         local Perp = Vector3.Cross(GroundDirection, Vector3.up)
         NewAimPoint = NewAimPoint + Perp * Evasion[1] * (2 * Mathf.PerlinNoise(Evasion[2] * Now, Offset) - 1)
      end

      self:SetThrust(I, Position, Velocity, AimPoint, MissileState, self.ClosingThrust, self.ClosingThrustAngle, TransceiverIndex, MissileIndex)

      return NewAimPoint
   end
end

function UnifiedMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   local TargetAltitude = TargetPosition.y

   self.TargetAltitude = TargetAltitude -- Raw altitude
   self.TargetDepth = math.min(TargetAltitude, 0) -- When below sea level
   self.TargetGround = math.max(I:GetTerrainAltitudeForPosition(TargetPosition), 0) -- When above sea level

   -- For now, performing the special attack is solely based on the target's
   -- elevation above sea level.
   self.DoSpecialAttack = (TargetAltitude - self.TargetGround) <= self.SpecialAttackElevation
end

function UnifiedMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile, MissileState)
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity

   local Fuel = MissileState.Fuel
   if not Fuel then
      -- Initialize state
      self:InitState(I, TransceiverIndex, MissileIndex, MissileState)
      Fuel = MissileState.Fuel
   end

   -- Determine time step
   local LastTime = MissileState.LastTime
   if not LastTime then LastTime = 0 end
   local Now = Missile.TimeSinceLaunch
   local TimeStep = Now - LastTime
   MissileState.LastTime = Now

   -- Integrate to figure out how much fuel was consumed since LastTime.
   -- Note that var thrust ramp up screws this up slightly.
   -- But it's better to overestimate the fuel than underestimate.
   if MissilePosition.y >= 0 then
      Fuel = Fuel - MissileState.CurrentThrust * TimeStep -- Assumes 1 fuel per thrust per second
   end
   MissileState.Fuel = math.max(Fuel, 0)

   local DetonationRange = self.DetonationRange
   if DetonationRange then
      local TargetVector = TargetAimPoint - MissilePosition
      local TargetRange = TargetVector.magnitude
      -- Check if we should detonate
      if TargetRange <= DetonationRange then
         -- Calculate angle between missile velocity and target vector
         local CosAngle = Vector3.Dot(TargetVector / TargetRange, MissileVelocity.normalized)
         if CosAngle <= self.DetonationAngle then
            I:DetonateLuaControlledMissile(TransceiverIndex, MissileIndex)
            return TargetAimPoint -- Don't really care at this point
         end
      end
   end

   local AimPoint,ImpactTime = QuadraticIntercept(MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity, 9999)

   local ResetThrust = true
   local MinimumAltitude = self.MinimumAltitude
   if MissilePosition.y < MinimumAltitude then
      -- Below minimum altitude, head straight up
      AimPoint = Vector3(MissilePosition.x, MinimumAltitude+1000, MissilePosition.z)
   elseif self.DoSpecialAttack then
      local Offset = TransceiverIndex * 37 + MissileIndex -- Used for Perlin noise lookup
      AimPoint = self:SpecialAttack(I, MissilePosition, MissileVelocity, AimPoint, Offset, MissileState, TransceiverIndex, MissileIndex, ImpactTime)
      ResetThrust = false
   end

   if ResetThrust then
      -- Reset thrust in case target elevation changed and we cancelled the special attack
      self:SetThrust(I, MissilePosition, MissileVelocity, AimPoint, MissileState, self.DefaultThrust, nil, TransceiverIndex, MissileIndex)
   end

   return AimPoint
end
