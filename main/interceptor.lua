--! interceptor
--@ periodic
function GatherWarnings(I)
   local Warnings = {}
   local WarningsById = {}

   for mindex=0,I:GetNumberOfMainframes()-1 do
      for windex=0,I:GetNumberOfWarnings(mindex)-1 do
         local Missile = I:GetMissileWarning(mindex, windex)
         -- TODO Closing check?
         if Missile.Valid and Missile.Range <= 1000 then
            local MissileId = Missile.Id
            table.insert(Warnings, MissileId)
            WarningsById[MissileId] = {
               Id = MissileId,
               MainframeIndex = mindex,
               WarningIndex = windex,
               Position = Missile.Position,
            }
         end
      end
   end

   return Warnings, WarningsById
end

-- IDs of missiles that have already been assigned
InterceptAssignments = {}
InterceptAssignmentsByWarning = {}

function Interceptor_Update(I)
   local Warnings,WarningsById = GatherWarnings(I)
   if #Warnings > 0 then

      local NewInterceptAssignments = {}
      local NewInterceptAssignmentsByWarning = {}

      for tindex=0,I:GetLuaTransceiverCount()-1 do
         for mindex=0,I:GetLuaControlledMissileCount(tindex)-1 do
            if I:IsLuaControlledMissileAnInterceptor(tindex, mindex) then
               local Missile = I:GetLuaControlledMissileInfo(tindex, mindex)
               if Missile.Valid then
                  local MissileId = Missile.Id
                  local JustLaunched = Missile.TimeSinceLaunch < 1
                  local Assignment = InterceptAssignments[MissileId]
                  if not Assignment then
                     local Warning = nil
                     local ClosestDistance = math.huge -- Actually squared
                     for windex=1,#Warnings do
                        local WarningId = Warnings[windex]
                        if JustLaunched then
                           -- If just launched, take first unassigned warning
                           if not InterceptAssignmentsByWarning[WarningId] then
                              Warning = WarningsById[WarningId]
                              break
                           end
                        else
                           -- Otherwise, just go after closest
                           local Candidate = WarningsById[WarningId]
                           -- Compute distance from this missile,
                           -- assign if closer than current
                           local Offset = Candidate.Position - Missile.Position
                           local Distance = Offset.sqrMagnitude
                           if Distance < ClosestDistance then
                              ClosestDistance = Distance
                              Warning = Candidate
                           end
                        end
                     end

                     if Warning then
                        -- Found at least one, send it on its way
                        local WarningId = Warning.Id
                        --I:LogToHud(string.format("Missile %s to %s", MissileId, WarningId))
                        if JustLaunched then
                           -- Take note of new assignment
                           NewInterceptAssignments[MissileId] = WarningId
                           NewInterceptAssignmentsByWarning[WarningId] = MissileId

                           -- Also ensure new missiles this update don't pick up the newly-assigned warning
                           InterceptAssignmentsByWarning[WarningId] = MissileId
                        end

                        -- And actually assign the missile
                        I:SetLuaControlledMissileInterceptorTarget(tindex, mindex, Warning.MainframeIndex, Warning.WarningIndex)
                     end
                  elseif WarningsById[Assignment] then
                     -- Move info to next update if warning still valid
                     NewInterceptAssignments[MissileId] = Assignment
                     NewInterceptAssignmentsByWarning[Assignment] = MissileId
                  end
               end
            end
         end
      end

      -- Overwrite old tables (so dead/stale data is deleted)
      InterceptAssignments = NewInterceptAssignments
      InterceptAssignmentsByWarning = NewInterceptAssignmentsByWarning
   end
end

Interceptor = Periodic.create(UpdateRate, Interceptor_Update)

Now = 0

function Update(I)
   if not I:IsDocked() then
      Now = I:GetTimeSinceSpawn()
      Interceptor:Tick(I)
   end
end
