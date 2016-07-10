-- MissileDriver module
LastTransceiverCount = 0
TransceiverGuidances = {}
MissileTargets = {}
LastTimeTargetSeen = nil

function GatherTargets(I, GuidanceInfos)
   local TargetsByPriority = {}
   local TargetsById = {}

   for mindex = 0,I:GetNumberOfMainframes()-1 do
      for tindex = 0,I:GetNumberOfTargets(mindex)-1 do
         local TargetInfo = I:GetTargetInfo(mindex, tindex)
         if TargetInfo.Valid and TargetInfo.Protected then
            local Position = TargetInfo.Position
            local Target = {
               Id = TargetInfo.Id,
               Position = Position,
               AimPoint = TargetInfo.AimPointPosition,
               Velocity = TargetInfo.Velocity,
            }
            local CanTarget = {}
            for _,GuidanceInfo in pairs(GuidanceInfos) do
               table.insert(CanTarget, GuidanceInfo.CanTarget(I, TargetInfo))
            end
            Target.CanTarget = CanTarget
            table.insert(TargetsByPriority, Target)
            TargetsById[TargetInfo.Id] = Target
         end
      end
   end

   return TargetsByPriority, TargetsById
end

function MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
   local Now = I:GetTimeSinceSpawn()
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
               local MissileTargetId = MissileTargets[Missile.Id]
               if not MissileTargetId then
                  -- Brand new missile, select highest priority that
                  -- this missile can target
                  for _,Target in pairs(TargetsByPriority) do
                     if Target.CanTarget[GuidanceIndex] then
                        MissileTargetId = Target.Id
                        NewMissileTargets[Missile.Id] = MissileTargetId
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
                     local ClosestDistance = math.huge -- Actually squared
                     for _,T in pairs(TargetsByPriority) do
                        if T.CanTarget[GuidanceIndex] then
                           local Offset = T.Position - Missile.Position
                           local Distance = Offset.sqrMagnitude

                           if Distance < ClosestDistance then
                              MissileTargetId = T.Id
                              NewMissileTargets[Missile.Id] = MissileTargetId
                              Target = T

                              ClosestDistance = Distance
                           end
                        end
                     end
                  else
                     -- Save for next loop
                     NewMissileTargets[Missile.Id] = MissileTargetId
                  end
               end

               if Target then
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
            local AimPoint = Guidance.Controller:Guide(I, tindex, mindex, TargetPosition, TargetAimPoint, TargetVelocity, QueueMissile.Missile, Now)

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
