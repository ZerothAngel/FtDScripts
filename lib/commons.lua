-- Commons module

-- The one global that holds the Commons instance.
-- A new instance MUST be instantiated every update.
C = nil

-- Presumably, calling a Lua binding is slow, especially methods
-- that return tables. Only call API when we need something and cache
-- the result for the lifetime of the instance.
function Commons.create(I, AttackSalvage)
   local self = {}

   self.I = I
   self.AttackSalvage = AttackSalvage
   self._FriendliesById = {}

   -- Can't implement "properties" because no metatable
   -- Since everything is read-only anyway, we'll just implement
   -- everything as lazy-init instance getters.

   -- Time
   self.Now = Commons.Now

   -- Miscellaneous
   self.IsDocked = Commons.IsDocked

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

   -- Targets
   self.GatherTargets = Commons.GatherTargets -- Private
   self.FirstTarget = Commons.FirstTarget
   self.Targets = Commons.Targets

   -- Friendlies
   self.Friendlies = Commons.Friendlies
   self.FriendlyById = Commons.FriendlyById

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
      Speed = WeaponInfo.Speed,
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

function Commons.ConvertTarget(Index, TargetInfo, Offset, Range)
   local Target = {
      Id = TargetInfo.Id,
      Index = Index,
      Position = TargetInfo.Position,
      Offset = Offset,
      Range = Range,
      SqrRange = Range * Range,
      AimPoint = TargetInfo.AimPointPosition,
      Velocity = TargetInfo.Velocity,
   }
   return Target
end

function Commons:GatherTargets(Targets, StartIndex, MaxTargets)
   local CoM = self:CoM()
   local AttackSalvage = self.AttackSalvage
   -- Query mainframes in the preferred order
   for _,mindex in ipairs(Commons.PreferredTargetMainframes) do
      local TargetCount = self.I:GetNumberOfTargets(mindex)
      if TargetCount > 0 then
         if not StartIndex then StartIndex = 0 end
         if not MaxTargets then MaxTargets = math.huge end
         for tindex = StartIndex,TargetCount-1 do
            if #Targets >= MaxTargets then break end
            local TargetInfo = self.I:GetTargetInfo(mindex, tindex)
            -- Will probably never not be valid, but eh, check anyway
            if TargetInfo.Valid and (TargetInfo.Protected or AttackSalvage) then
               local Offset = TargetInfo.Position - CoM
               local Range = Offset.magnitude
               if Range <= Commons.MaxEnemyRange then
                  table.insert(Targets, Commons.ConvertTarget(tindex, TargetInfo, Offset, Range))
               end
            end
         end
         -- Whether or not we actually added new targets, we have a definitive
         -- answer.
         -- All AIs see the same targets, so stop after one has been
         -- successfully queried.
         -- Note can't distinguish between non-existant mainframe
         -- and no targets.
         break
      end
   end
end

function Commons:FirstTarget()
   if not self._FirstTarget then
      -- Did we already gather all targets?
      if self._Targets then
         -- Use first one
         local Target = self._Targets[1]
         self._FirstTarget = Target and { Target } or {}
      else
         -- Just fetch first target, if any
         local Targets = {}
         self:GatherTargets(Targets, 0, 1)
         self._FirstTarget = Targets
      end
   end
   -- Note self._FirstTarget is a table of at most size 1, which allows it
   -- to be distinguished between uninitialized and no target.
   return self._FirstTarget[1]
end

function Commons:Targets()
   if not self._Targets then
      local Targets = {}
      -- Do we have a first target already?
      if self._FirstTarget then
         local Target = self._FirstTarget[1]
         if not Target then
            -- First target was already set, but there is no target.
            -- Definitely no more beyond that.
            self._Targets = {}
            return self._Targets
         end
         -- Copy the first target
         table.insert(Targets, Target)
         -- And continue off after first target
         self:GatherTargets(Targets, Target.Index+1)
      else
         -- Gather from start
         self:GatherTargets(Targets, 0)
      end
      self._Targets = Targets
   end
   return self._Targets
end

function Commons:Friendlies()
   if not self._Friendlies then
      local Friendlies = {}
      for findex = 0,self.I:GetFriendlyCount()-1 do
         local FriendlyInfo = self.I:GetFriendlyInfo(findex)
         if FriendlyInfo.Valid then -- Pointless check?
            table.insert(Friendlies, FriendlyInfo)
            -- Pre/re-populate ID mapping
            self._FriendliesById[FriendlyInfo.Id] = FriendlyInfo
         end
      end
      self._Friendlies = Friendlies
   end
   return self._Friendlies
end

function Commons:FriendlyById(Id)
   local FriendlyInfo = self._FriendliesById[Id]
   if not FriendlyInfo then
      FriendlyInfo = self.I:GetFriendlyInfoById(Id)
      -- Valid will be false if it doesn't exist, but save
      -- the table regardless so we don't check again
      self._FriendliesById[Id] = FriendlyInfo
   end
   return FriendlyInfo
end
