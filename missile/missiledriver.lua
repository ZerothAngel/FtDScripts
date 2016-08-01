-- MissileDriver module
LastTransceiverCount = 0
TransceiverGuidances = {}
MissileTargets = {}
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

function MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
   local TargetsByPriority, TargetsById = GatherTargets(I, GuidanceInfos)
   if #TargetsByPriority > 0 then
      LastTimeTargetSeen = Now

      local TransceiverCount = I:GetLuaTransceiverCount()
      if TransceiverCount ~= LastTranceiverCount then
         -- Reset cached guidances if transceiver count changed
         -- (most likely due to damage or repair)
         TransceiverGuidances = {}
         LastTransceiverCount = TransceiverCount
      end

      -- Missiles that are currently active are saved here. Then the old
      -- table is overwritten.
      local NewMissileTargets = {}

      -- We want to group missiles up by target so SetTarget methods are only
      -- called once per target. This is done here.
      local GuidanceQueue = {}

      for tindex = 0,TransceiverCount-1 do
         local GuidanceIndex = TransceiverGuidances[tindex]
         if not GuidanceIndex then
            -- Select guidance and cache it
            local BlockInfo = I:GetLuaTransceiverInfo(tindex)
            GuidanceIndex = SelectGuidance(I, BlockInfo)
            TransceiverGuidances[tindex] = GuidanceIndex
         end

         local Guidance = GuidanceInfos[GuidanceIndex]

         for mindex = 0,I:GetLuaControlledMissileCount(tindex)-1 do
            local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
            if Missile.Valid then
               local MissileId = Missile.Id
               local MissileTargetId = MissileTargets[MissileId]
               if not MissileTargetId then
                  -- Brand new missile, select highest priority that
                  -- this missile can target
                  for _,Target in pairs(TargetsByPriority) do
                     if Target.CanTarget[GuidanceIndex] and Target.InRange[GuidanceIndex] then
                        MissileTargetId = Target.Id
                        NewMissileTargets[MissileId] = MissileTargetId
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
                              NewMissileTargets[MissileId] = MissileTargetId
                              Target = T

                              ClosestDistance = Distance
                           end
                        end
                     end
                  else
                     -- Save for next update
                     NewMissileTargets[MissileId] = MissileTargetId
                  end
               end

               if Target then
                  -- Add queue entry to guide this missile to its target (once all
                  -- missiles have been checked)
                  QueueMissiles = GuidanceQueue[Target.Id]
                  if not QueueMissiles then
                     -- First time we've queued up for this target this update
                     QueueMissiles = {}
                     GuidanceQueue[Target.Id] = QueueMissiles
                  end
                  QueueMissile = {
                     TransceiverIndex = tindex,
                     MissileIndex = mindex,
                     GuidanceIndex = GuidanceIndex,
                     Missile = Missile
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
            local AimPoint = Guidance.Controller:Guide(I, tindex, mindex, TargetPosition, TargetAimPoint, TargetVelocity, QueueMissile.Missile)

            I:SetLuaControlledMissileAimPoint(tindex, mindex, AimPoint.x, AimPoint.y, AimPoint.z)
         end
      end

      -- Overwrite old targets with newly-saved targets. Gets rid of
      -- dead missiles.
      MissileTargets = NewMissileTargets
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
