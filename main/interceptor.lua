--! interceptor
--@ commonswarnings commonsweapons commons periodic quadraticintercept weapontypes
function GatherWarnings()
   local Warnings = {}
   local WarningsById = {}

   for _,Missile in pairs(C:MissileWarnings()) do
      if Missile.Range <= MissileInterceptorRange then
         --# Note that closing check seems to make it more ineffective since
         --# VLS missiles won't initially be heading this way.
         local MissileId = Missile.Id
         table.insert(Warnings, Missile)
         WarningsById[MissileId] = Missile
      end
   end

   return Warnings, WarningsById
end

-- IDs of missiles that have already been assigned
InterceptAssignments = {}
InterceptAssignmentsByWarning = {}

function Interceptor_Update(I)
   local Warnings,WarningsById = GatherWarnings()
   if #Warnings > 0 then

      --# TODO Only launch if there are unassigned warnings
      if MissileInterceptorWeaponSlot then
         -- Just "aim" at first warning
         local AimPoint = Warnings[1].Position
         for _,Weapon in pairs(C:WeaponControllers()) do
            if Weapon.Slot == MissileInterceptorWeaponSlot and (Weapon.Type == TURRET or Weapon.Type == MISSILECONTROL) and not Weapon.PlayerControl then
               if I:AimWeaponInDirectionOnSubConstruct(Weapon.SubConstructId, Weapon.Index, AimPoint.x, AimPoint.y, AimPoint.z, MissileInterceptorWeaponSlot) > 0 and Weapon.Type == MISSILECONTROL then
                  I:FireWeaponOnSubConstruct(Weapon.SubConstructId, Weapon.Index, MissileInterceptorWeaponSlot)
               end
            end
         end
      end

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
                     for _,W in ipairs(Warnings) do
                        local WarningId = W.Id
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

                        if GuideMissileInterceptors then
                           Assignment = WarningId
                        else
                           -- And actually assign the missile
                           I:SetLuaControlledMissileInterceptorTarget(tindex, mindex, Warning.MainframeIndex, Warning.Index)
                        end
                     end
                  elseif WarningsById[Assignment] then
                     -- Move info to next update if warning still valid
                     NewInterceptAssignments[MissileId] = Assignment
                     NewInterceptAssignmentsByWarning[Assignment] = MissileId
                  end

                  if GuideMissileInterceptors then
                     local Warning = WarningsById[Assignment]
                     if Warning then
                        -- And guide the missile
                        I:SetLuaControlledMissileInterceptorStandardGuidanceOnOff(tindex, mindex, false)
                        local AimPoint = QuadraticIntercept(Missile.Position, Vector3.Dot(Missile.Velocity, Missile.Velocity), Warning.Position, Warning.Velocity, 9999)
                        I:SetLuaControlledMissileAimPoint(tindex, mindex, AimPoint.x, AimPoint.y, AimPoint.z)
                     end
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

Interceptor = Periodic.new(UpdateRate, Interceptor_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      Interceptor:Tick(I)
   end
end
