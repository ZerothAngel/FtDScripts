-- MissileDriver module
LastTransceiverCount = 0
TransceiverGuidances = {}
LastTransceiverResetTime = 0
MissileStates = {}
LastTimeTargetSeen = nil

function GatherTargets(I, GuidanceInfos)
   local TargetsByPriority = {}
   local TargetsById = {}

   local Position = I:GetConstructPosition()

   for _,mindex in pairs(PreferredMainframes) do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         local TargetInfo = I:GetTargetInfo(mindex, tindex)
         -- Only if valid and isn't salvage
         if TargetInfo.Valid and TargetInfo.Protected then
            local TargetId = TargetInfo.Id
            local TargetPosition = TargetInfo.Position
            local Target = {
               Id = TargetId,
               Position = TargetPosition,
               AimPoint = TargetInfo.AimPointPosition,
               Velocity = TargetInfo.Velocity,
            }
            local CanTarget = {}
            local InRange = {}
            local Altitude = TargetPosition.y
            local Range = (TargetPosition - Position).sqrMagnitude
            for _,GuidanceInfo in pairs(GuidanceInfos) do
               table.insert(CanTarget, Altitude >= GuidanceInfo.MinAltitude and Altitude <= GuidanceInfo.MaxAltitude)
               table.insert(InRange, Range >= GuidanceInfo.MinRange and Range <= GuidanceInfo.MaxRange)
            end
            Target.CanTarget = CanTarget
            Target.InRange = InRange
            table.insert(TargetsByPriority, Target)
            TargetsById[TargetId] = Target
         end
      end

      -- Currently, all AIs seemingly see all targets. Once we've successfully queried one,
      -- there's no point in querying the others.
      -- NB Can't distinguish between querying a dead mainframe and getting no targets...
      if #TargetsByPriority > 0 then break end
   end

   return TargetsByPriority, TargetsById
end

function MissileDriver_FireControl(I, GuidanceInfos, TargetsByPriority)
   local SlotsToFire = {}
   local Fire = false
   for i = 1,#GuidanceInfos do
      local Guidance = GuidanceInfos[i]
      local WeaponSlot = Guidance.WeaponSlot
      if WeaponSlot then
         for _,Target in pairs(TargetsByPriority) do
            -- Range isn't all that accurate since it's range from Position, not turret/controller, but eh...
            if Target.CanTarget[i] and Target.InRange[i] then
               -- Respect priority and don't bother with leading the target
               if not SlotsToFire[WeaponSlot] then
                  SlotsToFire[WeaponSlot] = Target.AimPoint
                  Fire = true
               end
               break -- No need to check more targets
            end
         end
      end
   end

   -- Only bother if there are slots to fire
   if Fire then
      for i = 0,I:GetWeaponCount()-1 do
         local Info = I:GetWeaponInfo(i)
         local WeaponSlot = Info.WeaponSlot
         local AimPoint = SlotsToFire[WeaponSlot]
         if AimPoint and not Info.PlayerCurrentlyControllingIt then
            local WeaponType = Info.WeaponType
            -- Top-level turrets and missile controllers only
            if WeaponType == 4 or WeaponType == 5 then
               -- Relative to weapon position
               local Offset = AimPoint - Info.GlobalPosition
               if I:AimWeaponInDirection(i, Offset.x, Offset.y, Offset.z, WeaponSlot) > 0 then
                  I:FireWeapon(i, WeaponSlot)
               end
            end
         end
      end
   end
end

function MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
   local TargetsByPriority, TargetsById = GatherTargets(I, GuidanceInfos)
   if #TargetsByPriority > 0 then
      LastTimeTargetSeen = Now

      MissileDriver_FireControl(I, GuidanceInfos, TargetsByPriority)

      local TransceiverCount = I:GetLuaTransceiverCount()
      if TransceiverCount ~= LastTransceiverCount or (LastTransceiverResetTime+TransceiverResetInterval) < Now then
         -- Reset cached guidances if transceiver count changed
         -- (most likely due to damage or repair or timer timed out)
         TransceiverGuidances = {}
         LastTransceiverCount = TransceiverCount
         LastTransceiverResetTime = Now
      end

      -- Missiles that are currently active are saved here. Then the old
      -- table is overwritten.
      local NewMissileStates = {}

      -- We want to group missiles up by target so SetTarget methods are only
      -- called once per target. This is done here.
      local GuidanceQueue = {}

      for tindex = 0,TransceiverCount-1 do
         local GuidanceIndex = TransceiverGuidances[tindex]
         if not GuidanceIndex then
            -- Select guidance and cache it
            GuidanceIndex = SelectGuidance(I, tindex)
            TransceiverGuidances[tindex] = GuidanceIndex
         end

         for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
            local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
            if Missile.Valid then
               local MissileId = Missile.Id
               local MissileState = MissileStates[MissileId]
               if not MissileState then MissileState = {} end
               local MissileTargetId = MissileState.TargetId
               if not MissileTargetId then
                  -- Brand new missile, select highest priority that
                  -- this missile can target
                  for _,Target in pairs(TargetsByPriority) do
                     if Target.CanTarget[GuidanceIndex] and Target.InRange[GuidanceIndex] then
                        MissileTargetId = Target.Id
                        MissileState.TargetId = MissileTargetId
                        NewMissileStates[MissileId] = MissileState
                        break
                     end
                  end
               end

               local Target = nil

               -- Now check if the target is still around
               if MissileTargetId then
                  Target = TargetsById[MissileTargetId]
                  if not Target then
                     -- Saved target is gone, select closest target that
                     -- this missile can target
                     local MissilePosition = Missile.Position
                     local ClosestDistance = math.huge -- Actually squared
                     for _,T in pairs(TargetsByPriority) do
                        if T.CanTarget[GuidanceIndex] then
                           local Offset = T.Position - MissilePosition
                           local Distance = Offset.sqrMagnitude

                           if Distance < ClosestDistance then
                              MissileTargetId = T.Id
                              MissileState.TargetId = MissileTargetId
                              NewMissileStates[MissileId] = MissileState
                              Target = T

                              ClosestDistance = Distance
                           end
                        end
                     end
                  else
                     -- Save for next update
                     NewMissileStates[MissileId] = MissileState
                  end
               end

               if Target then
                  -- Add queue entry to guide this missile to its target (once all
                  -- missiles have been checked)
                  local QueueMissiles = GuidanceQueue[Target.Id]
                  if not QueueMissiles then
                     -- First time we've queued up for this target this update
                     QueueMissiles = {}
                     GuidanceQueue[Target.Id] = QueueMissiles
                  end
                  local QueueMissile = {
                     TransceiverIndex = tindex,
                     MissileIndex = mindex,
                     GuidanceIndex = GuidanceIndex,
                     Missile = Missile,
                     MissileState = MissileState,
                  }
                  table.insert(QueueMissiles, QueueMissile)
               end
            end
         end
      end

      -- Process guidance queue
      for TargetId,QueueMissiles in pairs(GuidanceQueue) do
         local Target = TargetsById[TargetId]
         local TargetPosition,TargetAimPoint,TargetVelocity = Target.Position,Target.AimPoint,Target.Velocity

         -- First call each controller's SetTarget method
         for _,GuidanceInfo in pairs(GuidanceInfos) do
            GuidanceInfo.Controller:SetTarget(I, TargetPosition, TargetAimPoint, TargetVelocity)
         end

         -- Now Guide each missile for this target
         for _,QueueMissile in pairs(QueueMissiles) do
            local Guidance = GuidanceInfos[QueueMissile.GuidanceIndex]
            local tindex,mindex = QueueMissile.TransceiverIndex,QueueMissile.MissileIndex
            local AimPoint = Guidance.Controller:Guide(I, tindex, mindex, TargetPosition, TargetAimPoint, TargetVelocity, QueueMissile.Missile, QueueMissile.MissileState)

            I:SetLuaControlledMissileAimPoint(tindex, mindex, AimPoint.x, AimPoint.y, AimPoint.z)
         end
      end

      -- Overwrite old states with newly-saved states. Gets rid of
      -- dead missiles.
      MissileStates = NewMissileStates
   elseif LastTimeTargetSeen and (LastTimeTargetSeen+DetonateAfter) < Now then
      LastTimeTargetSeen = nil

      -- Detonate all missiles
      for tindex = 0,I:GetLuaTransceiverCount()-1 do
         for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
            I:DetonateLuaControlledMissile(tindex, mindex)
         end
      end
   end
end
