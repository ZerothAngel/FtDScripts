--@ commons deepcopy planarvector round quadraticsolver
SimpleMine = {}

function SimpleMine.create(Config)
   local self = deepcopy(Config)

   -- Pre-square
   self.DropDistance = self.DropDistance * self.DropDistance

   self.BeginUpdate = SimpleMine.BeginUpdate
   self.Guide = SimpleMine.Guide

   return self
end

function SimpleMine.SendUpdate(I, TransceiverIndex, MissileIndex, NewState)
   local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)
   local BallastDepth,MagnetRange = NewState.BallastDepth,NewState.MagnetRange
   local Thrust = NewState.Thrust
   if not (BallastDepth or MagnetRange or Thrust) then return end
   for _,Part in pairs(MissileInfo.Parts) do
      if BallastDepth and Part.Name == "missile ballast" then
         Part:SendRegister(1, BallastDepth)
      elseif MagnetRange and Part.Name == "missile magnet" then
         Part:SendRegister(1, MagnetRange)
      elseif Thrust and Part.Name == "missile short range thruster" then
         Part:SendRegister(2, Thrust)
      end
   end
end

function SimpleMine:BeginUpdate(_, Targets)
   -- Should be filtered already, i.e. only targetable
   self.Targets = Targets
   self.FriendInfos = {}
end

function SimpleMine:Guide(I, TransceiverIndex, MissileIndex, _, TargetAimPoint, TargetVelocity, Missile, MissileState)
   local MissilePosition = Missile.Position

   -- Initialize state, if needed
   if not MissileState.Initialized then
      -- Read current ballast/magnet settings
      local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)
      for _,Part in pairs(MissileInfo.Parts) do
         -- Last one of each part wins
         if Part.Name == "missile ballast" then
            MissileState.BallastDepth = Part.Registers[1]
         elseif Part.Name == "missile magnet" then
            MissileState.MagnetRange = Part.Registers[1]
         elseif Part.Name == "missile short range thruster" then
            MissileState.Thrust = Part.Registers[2]
         end
      end

      MissileState.Initialized = true
   end

   local NewState = {}

   if MissileState.InWater or MissilePosition.y <= 0 then
      MissileState.InWater = true

      if MissileState.BallastDepth then
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
         NewDepth = -math.min(0, math.max(-500, NewDepth))

         -- Only change if different
         if NewDepth ~= MissileState.BallastDepth then
            NewState.BallastDepth = NewDepth
         end
      end

      if MissileState.MagnetRange then
         local MaxFriendlyAltitude = self.MaxFriendlyAltitude
         local MinFriendlyRange = self.MinFriendlyRange
         local NewMagnetRange = self.MagnetRange

         -- Scan for nearby friendlies
         for _,Friend in pairs(C:Friendlies()) do
            -- Only those below MaxFriendlyAltitude
            if Friend.CenterOfMass.y < MaxFriendlyAltitude then
               -- Already have midpoint and radius this update?
               local FriendInfo = self.FriendInfos[Friend.Id]
               if not FriendInfo then
                  -- Calculate approximate midpoint and radius using AABB
                  -- Very rough (no rotation since AABB), but conservative
                  local HalfSize = (Friend.AxisAlignedBoundingBoxMaximum - Friend.AxisAlignedBoundingBoxMinimum) / 2
                  -- Save for the other mines
                  FriendInfo = {
                     MidPoint = Friend.AxisAlignedBoundingBoxMinimum + HalfSize,
                     Radius = math.max(HalfSize.x, math.max(HalfSize.y, HalfSize.z)),
                  }
                  self.FriendInfos[Friend.Id] = FriendInfo
               end

               local Offset = FriendInfo.MidPoint - MissilePosition
               local Distance = FriendInfo.Radius + Offset.magnitude
               if Distance <= MinFriendlyRange then
                  -- Deactivate magnet, no need to check more
                  NewMagnetRange = 0
                  break
               end
            end
         end

         -- Only change if different
         if NewMagnetRange ~= MissileState.MagnetRange then
            NewState.MagnetRange = NewMagnetRange
         end
      end

      -- Cut thrust unconditionally
      if MissileState.Thrust ~= 0 then
         NewState.Thrust = 0
      end
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
         local Offset,_ = PlanarVector(TargetAimPoint + TargetVelocity * FallTime, ImpactPoint)
         -- If impact point < DropDistance, start next phase
         MissileState.InWater = Offset.sqrMagnitude <= self.DropDistance
      end
   end

   -- Make changes, update state
   SimpleMine.SendUpdate(I, TransceiverIndex, MissileIndex, NewState)

   if NewState.BallastDepth then
      MissileState.BallastDepth = NewState.BallastDepth
   end
   if NewState.MagnetRange then
      MissileState.MagnetRange = NewState.MagnetRange
   end
   if NewState.Thrust then
      MissileState.Thrust = NewState.Thrust
   end

   return nil -- No aim point, purely ballistic
end
