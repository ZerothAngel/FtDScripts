--@ shallowcopy
-- Commons module

-- The one global that holds the Commons instance.
-- A new instance MUST be instantiated every update.
C = nil

-- Presumably, calling a Lua binding is slow, especially methods
-- that return tables. Only call API when we need something and cache
-- the result for the lifetime of the instance.
Commons = {}

function Commons.new(I, AttackSalvage)
   local self = shallowcopy(Commons)

   self.I = I
   self.AttackSalvage = AttackSalvage
   self._FriendliesById = {}

   return self
end

function Commons:Now()
   if not self._Now then
      self._Now = self.I:GetTimeSinceSpawn()
   end
   return self._Now
end

function Commons:IsDocked()
   if not self._IsDocked then
      self._IsDocked = self.I:IsDocked()
   end
   return self._IsDocked
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
      self._Pitch = -self.I:GetConstructPitch()
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

function Commons:ToWorld()
   if not self._ToWorld then
      self._ToWorld = Quaternion.LookRotation(self:ForwardVector(), self:UpVector())
   end
   return self._ToWorld
end

function Commons:ToLocal()
   if not self._ToLocal then
      self._ToLocal = Quaternion.Inverse(self:ToWorld())
   end
   return self._ToLocal
end

function Commons:Ground()
   if not self._Ground then
      self._Ground = math.max(0, self.I:GetTerrainAltitudeForPosition(self:CoM()))
   end
   return self._Ground
end

