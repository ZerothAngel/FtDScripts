--@ pronav round
-- PN guided missile
ProNavMissile = {}

function ProNavMissile.create(Config, UpdateRate)
   local self = {}

   self.Gain = Config.Gain
   self.OneTurnTime = Config.OneTurnTime
   self.OneTurnAngle = math.cos(math.rad(Config.OneTurnAngle))
   self.DetonationRange = Config.DetonationRange
   self.DetonationAngle = math.cos(math.rad(Config.DetonationAngle))
   self.DefaultThrust = Config.DefaultThrust
   self.TerminalRange = Config.TerminalRange
   self.TerminalThrust = Config.TerminalThrust
   self.TerminalThrustAngle = Config.TerminalThrustAngle and math.cos(math.rad(Config.TerminalThrustAngle)) or nil

   self.InitState = ProNavMissile.InitState
   self.SetThrust = ProNavMissile.SetThrust
   self.SetTarget = ProNavMissile.SetTarget
   self.Guide = ProNavMissile.Guide

   return self
end

-- Initialize state, save info about missile
function ProNavMissile:InitState(I, TransceiverIndex, MissileIndex, MissileState)
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
function ProNavMissile:SetThrust(I, Position, Velocity, AimPoint, MissileState, Thrust, ThrustAngle, TransceiverIndex, MissileIndex)
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

function ProNavMissile:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity, TargetInfo)
   -- Nothing to do
end

function ProNavMissile:Guide(I, TransceiverIndex, MissileIndex, TargetPosition, TargetAimPoint, TargetVelocity, Missile, MissileState)
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

   local TargetVector = TargetAimPoint - MissilePosition
   local TargetRange = TargetVector.magnitude
   local MissileSpeed = MissileVelocity.magnitude
   -- Calculate angle between missile velocity and target vector
   local CosAngle = Vector3.Dot(TargetVector / TargetRange, MissileVelocity / MissileSpeed)

   -- Check if we should detonate
   if TargetRange <= self.DetonationRange and CosAngle <= self.DetonationAngle then
      I:DetonateLuaControlledMissile(TransceiverIndex, MissileIndex)
      return TargetAimPoint -- Don't really care at this point
   end

   -- Set thrust
   local TerminalRange = self.TerminalRange
   if TerminalRange and TargetRange <= TerminalRange then
      local Thrust = self.TerminalThrust
      if Thrust and Thrust < 0 then
         local ImpactTime = TargetRange / MissileSpeed -- Just fudge it
         -- Base terminal thrust on current fuel and predicted impact time
         Thrust = Round(MissileState.Fuel / ImpactTime, 1)
         -- Constrain (is this needed?)
         Thrust = math.max(50, math.min(10000, Thrust))
      end
      self:SetThrust(I, MissilePosition, MissileVelocity, TargetAimPoint, MissileState, Thrust, self.TerminalThrustAngle, TransceiverIndex, MissileIndex)
   else
      self:SetThrust(I, MissilePosition, MissileVelocity, TargetAimPoint, MissileState, self.DefaultThrust, nil, TransceiverIndex, MissileIndex)
   end

   -- Perform a "one turn" maneuver if newly-launched
   if Now <= self.OneTurnTime and CosAngle < self.OneTurnAngle then
      -- Just turn straight toward target
      return TargetAimPoint
   end

   return ProNav(self.Gain, TimeStep, MissilePosition, MissileVelocity, TargetAimPoint, TargetVelocity)
end
