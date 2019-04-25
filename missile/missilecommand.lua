--@ clamp
-- MissileCommand implementation
MissileCommand = {}

function MissileCommand.new(I, TransceiverIndex, MissileIndex)
   local self = {}

   -- Note we don't bother saving TransceiverIndex & MissileIndex in the
   -- instance because they may change.
   -- We leave tracking (by missile ID) to the caller.

   local Fuel,Lifetime,VarThrustCount,VarThrust,ThrustCount = 0,45,0,0,0

   local switch = {}
   -- All names have a spaces, so can't use shortcut
   switch["Variable Thruster"] = function (Part)
      VarThrustCount = VarThrustCount + 1
      VarThrust = VarThrust + Part.Registers[2]
   end
   switch["Fuel Tank"] = function (_)
      Fuel = Fuel + 10000
   end
   switch["Regulator"] = function (_)
      Lifetime = Lifetime + 180
   end
   switch["Short Range Thruster"] = function (Part)
      ThrustCount = ThrustCount + 1
      self.ThrustDelay = Part.Registers[1]
      self.ThrustDuration = Part.Registers[2]
   end
   switch["Magnet (for mines)"] = function (Part)
      self.MagnetRange = Part.Registers[1]
      self.MagnetDelay = Part.Registers[2]
   end
   switch["Ballast Tanks"] = function (Part)
      self.BallastDepth = Part.Registers[1]
      self.BallastBuoyancy = Part.Registers[2]
   end

   -- Read current settings
   local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)
   local parts = MissileInfo.Parts
   for i = 1,#parts do
      local Part = parts[i]
      -- For most parts, the last one looked at wins.
      -- Except var thrusters, fuel tanks, and regulators, which are summed.
      local f = switch[Part.Name]
      if f then f(Part) end
   end

   self.Fuel = Fuel
   self.Lifetime = Lifetime
   if VarThrustCount > 0 then
      self.VarThrustCount = VarThrustCount
      self.VarThrust = VarThrust
   end
   if ThrustCount > 0 then
      self.ThrustCount = ThrustCount
   end

   -- Methods
   self.SendUpdate = MissileCommand.SendUpdate

   return self
end

function MissileCommand.ShouldUpdate(Command, Current)
   return Command and Current and (Command ~= Current)
end

function MissileCommand:SendUpdate(I, TransceiverIndex, MissileIndex, Command)
   local switch = {}
   --# Is there really no way to get the size of a non-sequential table?
   local DoUpdate = false

   local ShouldUpdate = MissileCommand.ShouldUpdate
   if ShouldUpdate(Command.VarThrust, self.VarThrust) then
      -- Divide desired thrust among all variable thrusters
      local Thrust = Clamp(Command.VarThrust / self.VarThrustCount, 300, 3000)
      switch["Variable Thruster"] = function (Part)
         Part:SendRegister(2, Thrust)
      end
      self.VarThrust = Command.VarThrust
      DoUpdate = true
   end
   if ShouldUpdate(Command.ThrustDelay, self.ThrustDelay) or ShouldUpdate(Command.ThrustDuration, self.ThrustDuration) then
      local Delay = Command.ThrustDelay and Clamp(Command.ThrustDelay, 0, 20) or nil
      local Duration = Command.ThrustDuration and Clamp(Command.ThrustDuration, .1, 5) or nil
      switch["Short Range Thruster"] = function (Part)
         if Delay then Part:SendRegister(1, Delay) end
         if Duration then Part:SendRegister(2, Duration) end
      end
      if Delay then self.ThrustDelay = Delay end
      if Duration then self.ThrustDuration = Duration end
      DoUpdate = true
   end
   if ShouldUpdate(Command.MagnetRange, self.MagnetRange) or ShouldUpdate(Command.MagnetDelay, self.MagnetDelay) then
      local Range = Command.MagnetRange and Clamp(Command.MagnetRange, 5, 200) or nil
      local Delay = Command.MagnetDelay and Clamp(Command.MagnetDelay, 3, 30) or nil
      switch["Magnet (for mines)"] = function (Part)
         if Range then Part:SendRegister(1, Range) end
         if Delay then Part:SendRegister(2, Delay) end
      end
      if Range then self.MagnetRange = Range end
      if Delay then self.MagnetDelay = Delay end
      DoUpdate = true
   end
   if ShouldUpdate(Command.BallastDepth, self.BallastDepth) or ShouldUpdate(Command.BallastBuoyancy, self.BallastBuoyancy) then
      local Depth = Command.BallastDepth and Clamp(Command.BallastDepth, 0, 500) or nil
      local Buoyancy = Command.BallastBuoyancy and Clamp(Command.BallastBuoyancy, -.5, .5) or nil
      switch["Ballast Tanks"] = function (Part)
         if Depth then Part:SendRegister(1, Depth) end
         if Buoyancy then Part:SendRegister(2, Buoyancy) end
      end
      if Depth then self.BallastDepth = Depth end
      if Buoyancy then self.BallastBuoyancy = Buoyancy end
      DoUpdate = true
   end

   if DoUpdate then
      local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)
      local parts = MissileInfo.Parts
      for i = 1,#parts do
         local Part = parts[i]
         local f = switch[Part.Name]
         if f then f(Part) end
      end
   end
end
