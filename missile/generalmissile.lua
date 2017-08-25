--@ commons quadraticintercept pronav getvectorangle round deepcopy sign missilecommand
-- GeneralMissile implementation
GeneralMissile = {}

-- Returns cosine of Angle (given in degrees) or Default
function PrepareAngle(Angle, Default)
   return Angle and math.cos(math.rad(Angle)) or Default
end

function GeneralMissile.create(Config)
   local self = deepcopy(Config)

   -- If one config set or the other is missing, set defaults and activation
   -- appropriately
   if not self.AntiAir then
      self.ProfileActivationElevation = math.huge
      self.AntiAir = {
         Gain = 5,
      }
   elseif not self.Phases then
      self.ProfileActivationElevation = -math.huge
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
   self.DetonationAngle = PrepareAngle(self.DetonationAngle, 1)
   self.AntiAir.ThrustAngle = PrepareAngle(self.AntiAir.ThrustAngle)
   self.AntiAir.OneTurnAngle = PrepareAngle(self.AntiAir.OneTurnAngle, 1)
   for _,Phase in pairs(self.Phases) do
      if Phase.Change and Phase.Change.When then
         Phase.Change.When.Angle = PrepareAngle(Phase.Change.When.Angle)
      end
   end

   -- Handle certain nil values so they will always evaluate false
   if not self.DetonationRange then self.DetonationRange = -1 end
   if not self.AntiAir.OneTurnTime then self.AntiAir.OneTurnTime = -1 end

   -- Methods (because no setmetatable)
   self.GetTerrainHeight = GeneralMissile.GetTerrainHeight
   self.ModifyAltitude = GeneralMissile.ModifyAltitude
   self.GetPhaseAltitude = GeneralMissile.GetPhaseAltitude
   self.ExecuteProfile = GeneralMissile.ExecuteProfile
   -- "Public" methods
   self.SetTarget = GeneralMissile.SetTarget
   self.Guide = GeneralMissile.Guide

   return self
end

-- Update state, including fuel estimation
function UpdateMissileState(I, TransceiverIndex, MissileIndex, Position, Missile, MissileState)
   local Command = MissileState.Command
   if not Command then
      -- Initialize state
      MissileState.Command = MissileCommand.create(I, TransceiverIndex, MissileIndex)
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
         CurrentThrust = CurrentThrust + 1000
      end
      -- TODO torpedo props?
      Fuel = Fuel - CurrentThrust * TimeStep -- Assumes 1 fuel per thrust per second
   end
   MissileState.Fuel = math.max(Fuel, 0)

   return Now,TimeStep
end

-- Handle a missile state change
function HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, Velocity, AimPoint, MissileState, ImpactTime, Change)
   if not Change then return end

   if Change.When then
      -- Check conditions, exit if not met
      local TargetVector = AimPoint - Position
      if Change.When.Angle then
         -- Note we end up calculating this twice in certain circumstances,
         -- but that's ok
         -- Sometimes it's the predicted aim point, sometimes it's the real
         -- one
         local CosAngle = Vector3.Dot(TargetVector.normalized, Velocity.normalized)
         if CosAngle < Change.When.Angle then return end -- Not yet
      end
      if Change.When.Range then
         if TargetVector.magnitude > Change.When.Range then return end
      end
      if Change.When.AltitudeGT then
         if Position.y <= Change.When.AltitudeGT then return end
      end
      if Change.When.AltitudeLT then
         if Position.y >= Change.When.AltitudeLT then return end
      end
   end

   --# The following is a no-no since the config is shared between all
   --# missiles. But it's not like we're multithreaded...
   Change.VarThrust = Change.Thrust
   if Change.VarThrust and Change.VarThrust < 0 then
      -- Base thrust on current (estimated) fuel and predicted impact time
      Change.VarThrust = Round(MissileState.Fuel / ImpactTime, 1)
   end

   MissileState.Command:SendUpdate(I, TransceiverIndex, MissileIndex, Change)
end

-- Return highest terrain seen within look-ahead distance
function GeneralMissile:GetTerrainHeight(I, Position, Velocity, MaxDistance)
   if not MaxDistance then MaxDistance = math.huge end

   local LookAheadTime,LookAheadResolution = self.LookAheadTime,self.LookAheadResolution
   if not LookAheadTime or LookAheadResolution <= 0 then return -500 end

   local Height = -500
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

-- Modify altitude according to flavor
function GeneralMissile:GetPhaseAltitude(I, Position, Velocity, Phase, MaxDistance)
   local Height = self:GetTerrainHeight(I, Position, Velocity, MaxDistance)
   if Phase.AboveSeaLevel then
      -- Constrain terrain hugging to sea level
      Height = math.max(Height, 0)
   end
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
function GeneralMissile:ExecuteProfile(I, TransceiverIndex, MissileIndex, Position, Velocity, AimPoint, TargetVelocity, MissileState)
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

      HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, Velocity, AimPoint, MissileState, ImpactTime, TerminalPhase.Change)

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
   NewAimPoint.y = self:GetPhaseAltitude(I, Position, Velocity, Phase, ToNextPhase)
   -- Change state, if configured
   HandleMissileChange(I, TransceiverIndex, MissileIndex, Position, Velocity, NewAimPoint, MissileState, ImpactTime, Phase.Change)
   -- Perform horizontal evasion, if any
   local Evasion = Phase.Evasion
   if Evasion then
      local Perp = Vector3.Cross(GroundDirection, Vector3.up)
      -- Note this uses the global Now
      NewAimPoint = NewAimPoint + Perp * Evasion[1] * (2 * Mathf.PerlinNoise(Evasion[2] * C:Now(), TransceiverIndex * 37 + MissileIndex) - 1)
   end

   return NewAimPoint
end

function GeneralMissile:SetTarget(I, Target)
   local TargetAimPoint = Target.AimPoint
   local TargetAltitude = TargetAimPoint.y

   self.TargetAltitude = TargetAltitude -- Raw altitude
   self.TargetDepth = math.min(TargetAltitude, 0) -- When below sea level
   self.TargetGround = math.max(I:GetTerrainAltitudeForPosition(TargetAimPoint), 0) -- When above sea level

   -- For now, executing the profile is solely based on the target's
   -- elevation above sea level.
   self.DoExecuteProfile = (TargetAltitude - self.TargetGround) <= self.ProfileActivationElevation
end

function GeneralMissile:Guide(I, TransceiverIndex, MissileIndex, Target, Missile, MissileState)
   local TargetAimPoint = Target.AimPoint
   local MissilePosition = Missile.Position
   local MissileVelocity = Missile.Velocity
   local MissileSpeed = MissileVelocity.magnitude

   local Now,TimeStep = UpdateMissileState(I, TransceiverIndex, MissileIndex, MissilePosition, Missile, MissileState)

   -- Note these are against the true aim point
   local TargetVector = TargetAimPoint - MissilePosition
   local TargetRange = TargetVector.magnitude
   -- Calculate angle between missile velocity and target vector
   local CosAngle = Vector3.Dot(TargetVector / TargetRange, MissileVelocity / MissileSpeed)

   -- Check if we should detonate
   if TargetRange <= self.DetonationRange and CosAngle <= self.DetonationAngle then
      I:DetonateLuaControlledMissile(TransceiverIndex, MissileIndex)
      return TargetAimPoint -- Don't really care at this point
   end

   local AimPoint

   local OneTurnStart = MissileState.OneTurnStart
   local MinAltitude = self.MinAltitude

   if not OneTurnStart and MissilePosition.y >= MinAltitude then
      -- Record the first time it is above minimum altitude
      OneTurnStart = Now
      MissileState.OneTurnStart = Now
   end

   if MissilePosition.y < MinAltitude then
      -- Below minimum altitude, head straight up
      AimPoint = Vector3(MissilePosition.x, MinAltitude+1000, MissilePosition.z)
      -- Don't bother with setting thrust since they don't work underwater
   elseif self.DoExecuteProfile then
      -- Execute profile
      AimPoint = self:ExecuteProfile(I, TransceiverIndex, MissileIndex, MissilePosition, MissileVelocity, TargetAimPoint, Target.Velocity, MissileState)
   else
      -- Since PN sucks at large angles, perform a "one turn" maneuver
      -- if newly-launched
      if Now <= (self.AntiAir.OneTurnTime + OneTurnStart) and CosAngle <= self.AntiAir.OneTurnAngle then
         -- Just turn straight toward target
         AimPoint = TargetAimPoint
      else
         -- Use PN guidance
         AimPoint = ProNav(self.AntiAir.Gain, TimeStep, MissilePosition, MissileVelocity, TargetAimPoint, Target.Velocity)
      end
      -- Set thrust
      local Change = {
         Thrust = self.AntiAir.DefaultThrust,
         ThrustDuration = nil,
      }
      local TerminalRange = self.AntiAir.TerminalRange
      if TerminalRange and TargetRange <= TerminalRange then
         Change = {
            -- ThrustAngle should already be prepared
            When = { Angle = self.AntiAir.ThrustAngle },
            Thrust = self.AntiAir.Thrust,
            ThrustDuration = self.AntiAir.ThrustDuration,
         }
      end
      HandleMissileChange(I, TransceiverIndex, MissileIndex, MissilePosition, MissileVelocity, TargetAimPoint, MissileState, TargetRange / MissileSpeed, Change)
   end

   return AimPoint
end
