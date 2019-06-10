--@ commons quadraticintercept getvectorangle round deepcopy sign missilecommand
-- GeneralMissile implementation
GeneralMissile = {}

-- Returns cosine of Angle (given in degrees) or Default
function GeneralMissile_PrepareAngle(Angle, Default)
   return Angle and math.cos(math.rad(Angle)) or Default
end

-- Calculate minimum terminal distance
function GeneralMissile_MinTerminal(TurnRadius, AltitudeDelta)
   if TurnRadius <= AltitudeDelta then
      -- Simply the turn radius. Round up to nearest 25.
      return 25 * math.ceil(TurnRadius / 25)
   else
      -- Calculate and round up to nearest 25.
      local MinTerminal = math.sqrt(AltitudeDelta * (2 * TurnRadius - AltitudeDelta))
      return 25 * math.ceil(MinTerminal / 25)
   end
end

function GeneralMissile_DynamicDistances(Config)
   -- Need both velocity and turn rate
   local Velocity,TurnRate = Config.Velocity,Config.TurnRate
   if not Velocity or not TurnRate then return end

   local TurnRadius = Velocity / math.rad(TurnRate)
   local MinTerminal = function (AltitudeDelta)
      return GeneralMissile_MinTerminal(TurnRadius, math.abs(AltitudeDelta))
   end

   -- Scan each phase (of the 2D profile)
   for _,Phase in pairs(Config.Phases) do
      -- And only act on those that are a function
      if type(Phase.Distance) == "function" then
         -- Resolve actual distance by calling the function
         local NewDistance = Phase.Distance(MinTerminal, TurnRadius)
         Phase.Distance = NewDistance
      end
   end
end

function GeneralMissile.new(Config)
   local self = deepcopy(Config)

   -- If one config set or the other is missing, set defaults and activation
   -- appropriately
   if not self.AntiAir then
      self.AirProfileElevation = math.huge
      self.AntiAir = {
         Phases = {
            {
            },
         },
      }
   elseif not self.Phases then
      self.AirProfileElevation = -math.huge
      self.Phases = {
         {
            Distance = 150,
         },
         {
            Distance = 50,
            AboveSeaLevel = false,
            MinElevation = 0,
         },
      }
   end

   -- Calculate cosine of all angle parameters ahead of time
   self.DetonationAngle = GeneralMissile_PrepareAngle(self.DetonationAngle, 1)
   for _,Phase in pairs(self.AntiAir.Phases) do
      if Phase.Change and Phase.Change.When then
         Phase.Change.When.Angle = GeneralMissile_PrepareAngle(Phase.Change.When.Angle)
      end
   end
   for _,Phase in pairs(self.Phases) do
      if Phase.Change and Phase.Change.When then
         Phase.Change.When.Angle = GeneralMissile_PrepareAngle(Phase.Change.When.Angle)
      end
   end

   -- Handle certain nil values so they will always evaluate false
   if not self.DetonationRange then self.DetonationRange = -1 end

   -- Fix up 3D phases, if needed
   if #self.AntiAir.Phases == 1 then
      -- Only has terminal phase, set range appropriately
      self.AntiAir.Phases[1].Range = math.huge
      -- Add a dummy closing phase
      table.insert(self.AntiAir.Phases, {})
   end
   -- Set 3D closing range (currently unused)
   self.AntiAir.Phases[#self.AntiAir.Phases].Range = math.huge

   GeneralMissile_DynamicDistances(self)

   -- Methods (because no setmetatable)
   self.GetTerrainHeight = GeneralMissile.GetTerrainHeight
   self.ModifyAltitude = GeneralMissile.ModifyAltitude
   self.GetPhaseAltitude2D = GeneralMissile.GetPhaseAltitude2D
   self.ExecuteProfile2D = GeneralMissile.ExecuteProfile2D
   self.ExecuteProfile3D = GeneralMissile.ExecuteProfile3D
   -- "Public" methods
   self.SetTarget = GeneralMissile.SetTarget
   self.Guide = GeneralMissile.Guide

   return self
end

-- Update state, including fuel estimation
function GeneralMissile_UpdateMissileState(I, TransceiverIndex, MissileIndex, Position, Missile, MissileState)
   local Command = MissileState.Command
   if not Command then
      -- Initialize state
      MissileState.Command = MissileCommand.new(I, TransceiverIndex, MissileIndex)
      Command = MissileState.Command
      MissileState.Fuel = Command.Fuel
   end
   local Fuel = MissileState.Fuel

   -- Determine time step
   local LastTime = MissileState.LastTime
   if not LastTime then LastTime = 0 end
   local Now = Missile.TimeSinceLaunch
   local TimeStep = Now - LastTime
   MissileState.LastTime = Now
   -- Save for downstream methods
   MissileState.Now = Now
   MissileState.TimeStep = TimeStep

   -- Integrate to figure out how much fuel was consumed since LastTime.
   -- Note that var thrust ramp up screws this up slightly.
   -- But it's better to overestimate the fuel than underestimate.
   if Position.y >= 0 then
      -- Variable thrusters consume no fuel when underwater
      -- But torpedo props do. So this will be inaccurate if there are
      -- torpedo props...
      local CurrentThrust = Command.VarThrust or 0
      -- Also factor in short range thrusters, as long as they are still active
      if Command.ThrustCount and Now > Command.ThrustDelay and (Command.ThrustDelay + Command.ThrustDuration) > Now then
         CurrentThrust = CurrentThrust + MissileConst_ShortRangeFuelRate
      end
      -- TODO torpedo props?
      Fuel = Fuel - CurrentThrust * TimeStep -- Assumes 1 fuel per thrust per second
   end
   MissileState.Fuel = math.max(Fuel, 0)
end

-- Handle a missile state change
function GeneralMissile_HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, MissileState, ImpactTime, Change)
   if not Change then return end

   if Change.When then
      -- Check conditions, exit if not met
      if Change.When.Angle and MissileState.TargetCosAngle < Change.When.Angle then return end
      if Change.When.Range and MissileState.TargetRange > Change.When.Range then return end
      if Change.When.AltitudeGT and Position.y <= Change.When.AltitudeGT then return end
      if Change.When.AltitudeLT and Position.y >= Change.When.AltitudeLT then return end
   end

   --# The following is a no-no since the config is shared between all
   --# missiles. But it's not like we're multithreaded...
   Change.VarThrust = Change.Thrust
   if Change.VarThrust and Change.VarThrust < 0 then
      -- Use smaller of remaining lifetime or predicted impact time
      local Remaining = math.max(MissileState.Command.Lifetime - MissileState.Now, 0)
      ImpactTime = math.min(Remaining, ImpactTime)
      -- Base thrust on current (estimated) fuel and time horizon
      Change.VarThrust = (ImpactTime > 0) and Round(MissileState.Fuel / ImpactTime, 1) or math.huge
   end

   MissileState.Command:SendUpdate(I, TransceiverIndex, MissileIndex, Change)
end

function GeneralMissile_Vanilla_GetTerrainHeight(self, I, Position, Velocity, MaxDistance, AboveSeaLevel)
   if not MaxDistance then MaxDistance = math.huge end

   local Height = AboveSeaLevel and 0 or -500

   local LookAheadTime,LookAheadResolution = self.LookAheadTime,self.LookAheadResolution
   if not LookAheadTime or LookAheadResolution <= 0 then return Height end

   local PlanarVelocity = Vector3(Velocity.x, 0, Velocity.z)
   local Speed = PlanarVelocity.magnitude
   local Direction = PlanarVelocity / Speed

   local Distance = math.min(Speed * LookAheadTime, MaxDistance)

   for d = 0,Distance-1,LookAheadResolution do
      Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * d))
   end

   Height = math.max(Height, I:GetTerrainAltitudeForPosition(Position + Direction * Distance))

   return Height
end

function GeneralMissile_Modded_GetTerrainHeight(self, I, Position, Velocity, MaxDistance, AboveSeaLevel)
   if not MaxDistance then MaxDistance = math.huge end

   local Height = AboveSeaLevel and 0 or -500

   local LookAheadTime,LookAheadResolution = self.LookAheadTime,self.LookAheadResolution
   if not LookAheadTime or LookAheadResolution <= 0 then return Height end

   local Speed = Velocity.magnitude
   local Direction = Velocity / Speed

   local Distance = math.min(Speed * LookAheadTime, MaxDistance)

   local LookAhead = AboveSeaLevel and I.GetWaveOrTerrainAltitudeLookingAhead or I.GetTerrainAltitudeLookingAhead
   Height = math.max(Height, LookAhead(I, Position, Direction * Distance, LookAheadResolution))

   return Height
end

-- Return highest terrain seen within look-ahead distance
function GeneralMissile:GetTerrainHeight(I, Position, Velocity, MaxDistance, AboveSeaLevel)
   -- First run through, determine if modded extensions are available
   if I.GetWaveOrTerrainAltitudeLookingAhead and I.GetTerrainAltitudeLookingAhead then
      self.GetTerrainHeight = GeneralMissile_Modded_GetTerrainHeight
   else
      self.GetTerrainHeight = GeneralMissile_Vanilla_GetTerrainHeight
   end
   return self:GetTerrainHeight(I, Position, Velocity, MaxDistance, AboveSeaLevel)
end

-- Modify an altitude according to RelativeTo
function GeneralMissile:ModifyAltitude(Position, AimPoint, Altitude, RelativeTo)
   if not AimPoint then
      -- Relative to (constrained) target altitude
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
      elseif RelativeTo == 5 then
         -- "Altitude" is a lower bound
         return math.max(self.TargetAltitude, Altitude)
      elseif RelativeTo == 6 then
         -- "Altitude" is an upper bound
         return math.min(self.TargetAltitude, Altitude)
      else
         -- Absolute (no modification)
         return Altitude
      end
   else
      -- Relative to (constrained) aim point
      if RelativeTo == 1 then
         return AimPoint.y + Altitude
      elseif RelativeTo == 2 then
         return math.min(AimPoint.y, 0) + Altitude
      elseif RelativeTo == 3 then
         return math.max(AimPoint.y, 0) + Altitude
      elseif RelativeTo == 4 then
         return Position.y + Altitude
      elseif RelativeTo == 5 then
         return math.max(AimPoint.y, Altitude)
      elseif RelativeTo == 6 then
         return math.min(AimPoint.y, Altitude)
      else
         return Altitude
      end
   end
end

-- Modify altitude according to flavor (2D version)
function GeneralMissile:GetPhaseAltitude2D(I, Position, Velocity, Phase, MaxDistance)
   local Height = self:GetTerrainHeight(I, Position, Velocity, MaxDistance, Phase.AboveSeaLevel)
   Height = Height + Phase.MinElevation

   local Altitude = Phase.Altitude
   if not Altitude then
      -- Always relative to terrain.
      return Height
   else
      -- Relative to something, hugging terrain if necessary.
      return math.max(self:ModifyAltitude(Position, nil, Altitude, Phase.RelativeTo), Height)
   end
end

-- Adjust aim point according to current profile phase
function GeneralMissile:ExecuteProfile2D(I, TransceiverIndex, MissileIndex, Position, Velocity, AimPoint, TargetVelocity, MissileState)
   -- Use quadratic prediction to determine aim point and predicted impact time
   local ImpactTime
   AimPoint,ImpactTime = QuadraticIntercept(Position, Vector3.Dot(Velocity, Velocity), AimPoint, TargetVelocity, 9999)

   -- For sanity, range comparisons are done against ground distance
   local NewTarget = Vector3(AimPoint.x, Position.y, AimPoint.z)
   local GroundOffset = NewTarget - Position
   local GroundDistance = GroundOffset.magnitude

   -- First check if within terminal distance
   local TerminalPhase = self.Phases[1]
   if GroundDistance < TerminalPhase.Distance then
      -- Modify aim point, if configured to do so
      local Altitude = TerminalPhase.Altitude
      if Altitude then
         AimPoint = Vector3(AimPoint.x, self:ModifyAltitude(Position, AimPoint, Altitude, TerminalPhase.RelativeTo), AimPoint.z)
      end

      GeneralMissile_HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, MissileState, ImpactTime, TerminalPhase.Change)

      return AimPoint
   end

   -- The assumption is that the phases are in order, closest to farthest
   -- Except for the last, which is always the closing phase regardless of
   -- its Distance
   local PreviousPhase,IsClosing
   local Phase = TerminalPhase
   for i = 2,#self.Phases do
      PreviousPhase = Phase
      Phase = self.Phases[i]
      IsClosing = i == #self.Phases
      if GroundDistance < Phase.Distance then break end
      -- If it's the last one (closing phase), the loop will end anyway
   end

   local GroundDirection,ToNextPhase

   -- Rotate aim point, if configured to do so
   local ApproachAngle = Phase.ApproachAngle
   if ApproachAngle then
      -- "Forward" is based off target's velocity
      local TargetYaw = GetVectorAngle(TargetVelocity)
      -- Determines missile's relative bearing so we can pick a side if needed
      local MissileBearing = Mathf.DeltaAngle(TargetYaw, GetVectorAngle(Position - AimPoint))
      -- Aim point bearing in world coordinates
      local AimPointBearing = (TargetYaw + Sign(MissileBearing, 1) * ApproachAngle) % 360

      -- Better way to calculate this?
      local ModifiedAimPoint = AimPoint + Quaternion.Euler(0, AimPointBearing, 0) * (Vector3.forward * PreviousPhase.Distance)
      ModifiedAimPoint.y = Position.y
      local Offset = ModifiedAimPoint - Position

      ToNextPhase = Offset.magnitude
      GroundDirection = Offset / ToNextPhase
   else
      -- No aim point modification
      GroundDirection = GroundOffset / GroundDistance
      ToNextPhase = GroundDistance - PreviousPhase.Distance
   end

   -- New aim point is toward target at edge of next phase
   -- (or closing phase distance, if closing phase)
   local AimDistance = IsClosing and Phase.Distance or ToNextPhase
   local NewAimPoint = Position + GroundDirection * AimDistance

   -- Modify altitude according to parameters
   NewAimPoint.y = self:GetPhaseAltitude2D(I, Position, Velocity, Phase, ToNextPhase)
   -- Change state, if configured
   GeneralMissile_HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, MissileState, ImpactTime, Phase.Change)
   -- Perform horizontal evasion, if any
   local Evasion = Phase.Evasion
   if Evasion then
      local Perp = Vector3.Cross(GroundDirection, Vector3.up)
      -- Note this uses the global Now
      NewAimPoint = NewAimPoint + Perp * Evasion[1] * (2 * Mathf.PerlinNoise(Evasion[2] * C:Now(), TransceiverIndex * 37 + MissileIndex) - 1)
   end

   return NewAimPoint
end

function GeneralMissile:ExecuteProfile3D(I, TransceiverIndex, MissileIndex, Position, Velocity, AimPoint, TargetVelocity, MissileState)
   -- Use quadratic prediction to determine aim point and predicted impact time
   local ImpactTime
   AimPoint,ImpactTime = QuadraticIntercept(Position, Vector3.Dot(Velocity, Velocity), AimPoint, TargetVelocity, 9999)

   local TargetOffset = AimPoint - Position
   local TargetRange = TargetOffset.magnitude

   -- First check if within terminal distance
   local TerminalPhase = self.AntiAir.Phases[1]
   if TargetRange < TerminalPhase.Range then
      -- Modify aim point, if configured to do so
      local Altitude = TerminalPhase.Altitude
      if Altitude then
         AimPoint = Vector3(AimPoint.x, self:ModifyAltitude(Position, AimPoint, Altitude, TerminalPhase.RelativeTo), AimPoint.z)
      end

      GeneralMissile_HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, MissileState, ImpactTime, TerminalPhase.Change)

      return AimPoint
   end

   -- The assumption is that the phases are in order, closest to farthest
   -- Except for the last, which is always the closing phase regardless of
   -- its Range
   local PreviousPhase
   local Phase = TerminalPhase
   for i = 2,#self.AntiAir.Phases do
      PreviousPhase = Phase
      Phase = self.AntiAir.Phases[i]
      if TargetRange < Phase.Range then break end
      -- If it's the last one (closing phase), the loop will end anyway
   end

   local TargetDirection,ToNextPhase

   -- TODO ApproachAngle

   TargetDirection = TargetOffset / TargetRange
   ToNextPhase = TargetRange - PreviousPhase.Range

   -- New aim point is toward target at edge of next phase
   local NewAimPoint = Position + TargetDirection * ToNextPhase

   -- Modify altitude according to parameters
   local Altitude = Phase.Altitude
   if Altitude then
      NewAimPoint.y = self:ModifyAltitude(Position, nil, Altitude, Phase.RelativeTo)
   end
   -- Change state, if configured
   GeneralMissile_HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, MissileState, ImpactTime, Phase.Change)

   -- TODO Evasion

   return NewAimPoint
end

function GeneralMissile:SetTarget(I, Target)
   local TargetAimPoint = Target.AimPoint
   local TargetAltitude = TargetAimPoint.y

   self.TargetAltitude = TargetAltitude -- Raw altitude
   self.TargetDepth = math.min(TargetAltitude, 0) -- When below sea level
   self.TargetGround = Target:Ground(I)

   -- For now, which profile to execute is solely based on the target's
   -- elevation above sea level.
   self.Use2DProfile = (TargetAltitude - self.TargetGround) <= self.AirProfileElevation
end

function GeneralMissile:Guide(I, TransceiverIndex, MissileIndex, Target, Missile, MissileState)
   local TargetAimPoint = Target.AimPoint
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local MissileSpeed = MissileVelocity.magnitude

   GeneralMissile_UpdateMissileState(I, TransceiverIndex, MissileIndex, MissilePosition, Missile, MissileState)

   -- Note these are against the true aim point
   local TargetVector = TargetAimPoint - MissilePosition
   local TargetRange = TargetVector.magnitude
   -- Calculate angle between missile velocity and target vector
   local CosAngle = Vector3.Dot(TargetVector / TargetRange, MissileVelocity / MissileSpeed)
   -- Save for other downstream methods
   MissileState.TargetVector = TargetVector
   MissileState.TargetRange = TargetRange
   MissileState.TargetCosAngle = CosAngle

   -- Check if we should detonate
   if TargetRange <= self.DetonationRange and CosAngle <= self.DetonationAngle then
      I:DetonateLuaControlledMissile(TransceiverIndex, MissileIndex)
      return TargetAimPoint -- Don't really care at this point
   end

   local AimPoint

   local MinAltitude = self.MinAltitude
   if MissilePosition.y < MinAltitude then
      -- Below minimum altitude, head straight up
      AimPoint = Vector3(MissilePosition.x, MinAltitude+1000, MissilePosition.z)
      -- Don't bother with setting thrust since they don't work underwater
   elseif self.Use2DProfile then
      -- Execute 2D profile
      AimPoint = self:ExecuteProfile2D(I, TransceiverIndex, MissileIndex, MissilePosition, MissileVelocity, TargetAimPoint, Target.Velocity, MissileState)
   else
      -- Execute 3D profile
      AimPoint = self:ExecuteProfile3D(I, TransceiverIndex, MissileIndex, MissilePosition, MissileVelocity, TargetAimPoint, Target.Velocity, MissileState)
   end

   return AimPoint
end
