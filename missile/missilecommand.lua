--@ clamp
-- MissileCommand implementation
MissileCommand = {}

function MissileCommand.new(I, TransceiverIndex, MissileIndex)
   local self = {}

   -- Note we don't bother saving TransceiverIndex & MissileIndex in the
   -- instance because they may change.
   -- We leave tracking (by missile ID) to the caller.

   local Fuel,Lifetime,VarThrustCount,VarThrust,ThrustCount = 0,MissileConst_LifetimeStart,0,0,0

   local switch = {}
   switch[MissileConst_VarThrust] = function (Part)
      VarThrustCount = VarThrustCount + 1
      VarThrust = VarThrust + Part.Registers[2]
   end
   switch[MissileConst_FuelTank] = function (_)
      Fuel = Fuel + MissileConst_FuelAmount
   end
   switch[MissileConst_Regulator] = function (_)
      Lifetime = Lifetime + MissileConst_LifetimeAdd
   end
   switch[MissileConst_ShortRange] = function (Part)
      ThrustCount = ThrustCount + 1
      self.ThrustDelay = Part.Registers[1]
      self.ThrustDuration = Part.Registers[2]
   end
   switch[MissileConst_ShortRange] = function (Part)
      self.MagnetRange = Part.Registers[1]
      self.MagnetDelay = Part.Registers[2]
   end
   switch[MissileConst_BallastTank] = function (Part)
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

function MissileCommand:SendUpdate(I, TransceiverIndex, MissileIndex, Command)
   local switch = {}

   for _,Spec in pairs(MissileUpdateData) do
      local Queue = {}
      for RegName,RegInfo in pairs(Spec[2]) do
         local CommandVal = Command[RegName]
         local CurrentVal = self[RegName]
         -- Only if command is present and differs from current
         if CommandVal and CurrentVal and (CommandVal ~= CurrentVal) then
            local RegNo,RegMin,RegMax = unpack(RegInfo)
            -- TODO missile scaling on RegMin/RegMax
            -- Queue it up
            local NewVal = Clamp(CommandVal, RegMin, RegMax)
            table.insert(Queue, { RegNo, NewVal })
            self[RegName] = NewVal
         end
      end
      if #Queue == 1 then -- Want to avoid loop overhead inside the closure...
         switch[Spec[1]] = function (Part)
            Part:SendRegister(Queue[1][1], Queue[1][2])
         end
      elseif #Queue == 2 then -- ...so handle both cases explicitly.
         switch[Spec[1]] = function (Part)
            Part:SendRegister(Queue[1][1], Queue[1][2])
            Part:SendRegister(Queue[2][1], Queue[2][2])
         end
      end
   end

   if next(switch) then
      local MissileInfo = I:GetMissileInfo(TransceiverIndex, MissileIndex)
      local parts = MissileInfo.Parts
      for i = 1,#parts do
         local Part = parts[i]
         local f = switch[Part.Name]
         if f then f(Part) end
      end
   end
end
