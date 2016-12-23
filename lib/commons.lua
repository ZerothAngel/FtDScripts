-- The one global that holds the Commons instance.
-- A new instance MUST be instantiated every update.
C = nil

-- Commons implementation
Commons = {}

-- Presumably, calling a Lua binding is slow, especially methods
-- that return tables. Only call API when we need something and cache
-- the result for the lifetime of the instance.
function Commons.create(I)
   local self = {}

   self.I = I

   -- Can't implement "properties" because no metatable
   -- Since everything is read-only anyway, we'll just implement
   -- everything as lazy-init instance getters.

   -- Time
   self.Now = Commons.Now

   -- Position and attitude
   self.Position = Commons.Position
   self.CoM = Commons.CoM
   self.Altitude = Commons.Altitude
   self.Yaw = Commons.Yaw
   self.Pitch = Commons.Pitch
   self.Roll = Commons.Roll

   -- Velocity
   self.Velocity = Commons.Velocity
   self.ForwardSpeed = Commons.ForwardSpeed

   -- Orientation
   self.ForwardVector = Commons.ForwardVector
   self.UpVector = Commons.UpVector
   self.RightVector = Commons.RightVector
   self.ToGlobal = Commons.ToGlobal
   self.ToLocal = Commons.ToLocal

   -- Weapon controllers
   self.HullWeaponControllers = Commons.HullWeaponControllers
   self.TurretWeaponControllers = Commons.TurretWeaponControllers
   self.WeaponControllers = Commons.WeaponControllers

   -- Target info is a possibility for the future...

   return self
end

function Commons:Now()
   if not self._Now then
      self._Now = self.I:GetTimeSinceSpawn()
   end
   return self._Now
end

function Commons:Position()
   if not self._Position then
      self._Position = self.I:GetConstructPosition()
   end
   return self._Position
end

function Commons:CoM()
   if not self._CoM then
      self._CoM = self.I:GetConstructCenterOfMass()
   end
   return self._CoM
end

function Commons:Altitude()
   return self:CoM().y
end

function Commons:Yaw()
   if not self._Yaw then
      self._Yaw = self.I:GetConstructYaw()
   end
   return self._Yaw
end

function Commons:Pitch()
   if not self._Pitch then
      local Pitch = self.I:GetConstructPitch()
      if Pitch > 180 then
         Pitch = 360 - Pitch
      else
         Pitch = -Pitch
      end
      self._Pitch = Pitch
   end
   return self._Pitch
end

function Commons:Roll()
   if not self._Roll then
      local Roll = self.I:GetConstructRoll()
      if Roll > 180 then
         Roll = Roll - 360
      end
      self._Roll = Roll
   end
   return self._Roll
end

function Commons:Velocity()
   if not self._Velocity then
      self._Velocity = self.I:GetVelocityVector()
   end
   return self._Velocity
end

function Commons:ForwardSpeed()
   if not self._ForwardSpeed then
      self._ForwardSpeed = self.I:GetForwardsVelocityMagnitude()
   end
   return self._ForwardSpeed
end

function Commons:ForwardVector()
   if not self._ForwardVector then
      self._ForwardVector = self.I:GetConstructForwardVector()
   end
   return self._ForwardVector
end

function Commons:UpVector()
   if not self._UpVector then
      self._UpVector = self.I:GetConstructUpVector()
   end
   return self._UpVector
end

function Commons:RightVector()
   if not self._RightVector then
      self._RightVector = self.I:GetConstructRightVector()
   end
   return self._RightVector
end

function Commons:ToGlobal()
   if not self._ToGlobal then
      self._ToGlobal = Quaternion.LookRotation(self:ForwardVector(), self:UpVector())
   end
   return self._ToGlobal
end

function Commons:ToLocal()
   if not self._ToLocal then
      self._ToLocal = Quaternion.Inverse(self:ToGlobal())
   end
   return self._ToLocal
end

function Commons.AddWeapon(Weapons, WeaponInfo, TurretIndex, WeaponIndex)
   local Weapon = {
      Index = WeaponIndex,
      TurretIndex = TurretIndex,
      Type = WeaponInfo.WeaponType,
      Slot = WeaponInfo.WeaponSlot,
      Position = WeaponInfo.GlobalPosition,
      PlayerControl = WeaponInfo.PlayerCurrentlyControllingIt,
   }
   table.insert(Weapons, Weapon)
end

function Commons:HullWeaponControllers()
   if not self._HullWeaponControllers then
      local Weapons = {}
      for windex = 0,self.I:GetWeaponCount()-1 do
         local Info = self.I:GetWeaponInfo(windex)
         Commons.AddWeapon(Weapons, Info, nil, windex)
      end
      self._HullWeaponControllers = Weapons
   end
   return self._HullWeaponControllers
end

function Commons:TurretWeaponControllers()
   if not self._TurretWeaponControllers then
      local Weapons = {}
      for tindex = 0,self.I:GetTurretSpinnerCount()-1 do
         for windex = 0,self.I:GetWeaponCountOnTurretOrSpinner(tindex)-1 do
            local Info = self.I:GetWeaponInfoOnTurretOrSpinner(tindex, windex)
            Commons.AddWeapon(Weapons, Info, tindex, windex)
         end
      end
      self._TurretWeaponControllers = Weapons
   end
   return self._TurretWeaponControllers
end

function Commons:WeaponControllers()
   if not self._WeaponControllers then
      local Weapons = {}
      for _,Weapon in pairs(self:HullWeaponControllers()) do
         table.insert(Weapons, Weapon)
      end
      for _,Weapon in pairs(self:TurretWeaponControllers()) do
         table.insert(Weapons, Weapon)
      end
      self._WeaponControllers = Weapons
   end
   return self._WeaponControllers
end
