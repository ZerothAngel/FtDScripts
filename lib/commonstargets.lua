--@ commons
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
   for _,mindex in ipairs(CommonsTargetConfig.PreferredTargetMainframes) do
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
               if Range <= CommonsTargetConfig.MaxEnemyRange then
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
