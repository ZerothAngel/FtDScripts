--@ commonsfriends deepcopy planarvector round quadraticsolver missilecommand clamp
SmartMine = {}

function SmartMine.new(Config)
   local self = deepcopy(Config)

   -- Pre-square
   self.DropDistance = self.DropDistance * self.DropDistance
   self.MinFriendlyRange = self.MinFriendlyRange * self.MinFriendlyRange

   self.BeginUpdate = SmartMine.BeginUpdate
   self.Guide = SmartMine.Guide

   return self
end

function SmartMine:BeginUpdate(_, Targets)
   -- Should be filtered already, i.e. only targetable
   self.Targets = Targets
end

function SmartMine:Guide(I, TransceiverIndex, MissileIndex, TheTarget, Missile, MissileState)
   local MissilePosition = Missile.Position

   -- Initialize state, if needed
   if not MissileState.Initialized then
      MissileState.Command = MissileCommand.new(I, TransceiverIndex, MissileIndex)
      MissileState.LaunchPosition = MissilePosition
      MissileState.Initialized = true
   end

   local NewCommand = {}

   if MissileState.NoThrust or MissilePosition.y <= 0 then
      MissileState.NoThrust = true

      if MissileState.Command.BallastDepth then
         -- Set depth according to closest enemy
         local Closest,Selected = math.huge,nil
         for _,Target in pairs(self.Targets) do
            local Offset,_ = PlanarVector(MissilePosition, Target.AimPoint)
            local SqrDistance = Offset.sqrMagnitude
            if SqrDistance < Closest then
               Closest = SqrDistance
               Selected = Target
            end
         end
         -- No targets, nothing to do
         if not Selected then return nil end

         -- Round altitude to avoid unnecessary state changes
         local NewDepth = Round(Selected.AimPoint.y, 1)
         -- Add offset
         NewDepth = NewDepth + self.DepthOffset
         -- Constrain and negate (because ballast depth
         -- is supposed to be positive)
         NewCommand.BallastDepth = -Clamp(NewDepth, -500, -self.MinDepth)
      end

      if MissileState.Command.MagnetRange then
         local MaxFriendlyAltitude = self.MaxFriendlyAltitude
         local MinFriendlyRange = self.MinFriendlyRange
         local NewMagnetRange = self.MagnetRange

         -- Scan for nearby friendlies
         for _,Friend in pairs(C:Friendlies()) do
            local FriendCoM = Friend.CenterOfMass
            -- Only those below MaxFriendlyAltitude
            if FriendCoM.y < MaxFriendlyAltitude then
               local Offset = FriendCoM - MissilePosition
               local SqrDistance = Offset.sqrMagnitude
               if SqrDistance <= MinFriendlyRange then
                  -- Set magnet to minimum and no need to check more
                  NewMagnetRange = 5
                  break
               end
            end
         end

         NewCommand.MagnetRange = NewMagnetRange
      end

      -- Cut thrust unconditionally
      NewCommand.ThrustDuration = 0
   else
      -- Still above water
      local MissileVelocity = Missile.Velocity
      -- Estimate when mine would hit water if thruster cutoff now
      -- (drag not used in calculations... too bad)
      local Height = MissilePosition.y
      local a = .5 * I:GetGravityForAltitude(Height).y
      local b = MissileVelocity.y
      local c = Height
      local Solutions = QuadraticSolver(a, b, c)
      local FallTime = nil
      -- Pick smallest positive fall time
      if #Solutions == 1 then
         local t = Solutions[1]
         if t > 0 then FallTime = t end
      elseif #Solutions == 2 then
         local t1 = Solutions[1]
         local t2 = Solutions[2]
         if t1 > 0 then
            FallTime = t1
         elseif t2 > 0 then
            FallTime = t2
         end
      end

      if FallTime then
         -- Calculate estimated impact point
         local ImpactPoint = MissilePosition + MissileVelocity * FallTime
         -- And determine distance from target
         local Offset,NewTarget = PlanarVector(ImpactPoint, TheTarget.AimPoint + TheTarget.Velocity * FallTime)
         -- If impact point < DropDistance, or it's moving behind the
         -- target, start next phase
         MissileState.NoThrust = Offset.sqrMagnitude <= self.DropDistance or
            Vector3.Dot(NewTarget - ImpactPoint, NewTarget - MissileState.LaunchPosition) < 0
      end
   end

   -- Make changes, update state
   MissileState.Command:SendUpdate(I, TransceiverIndex, MissileIndex, NewCommand)

   return nil -- No aim point, purely ballistic
end
