--! shieldmanager
--@ api periodic
-- Re-do in terms of cosine
ShieldActivationAngle = math.cos(math.rad(ShieldActivationAngle))

LastShieldCount = 0
ShieldActivationTimes = {}

function ShieldManager_Update(I)
   local CoM = I:GetConstructCenterOfMass()

   local Targets = {}

   -- Gather enemies
   local MainframeIndex = 0 -- All mainframes see the same targets, just check one
   for i=0,I:GetNumberOfTargets(MainframeIndex)-1 do
      local TargetInfo = I:GetTargetInfo(MainframeIndex, i)
      if TargetInfo.Valid and TargetInfo.Protected then
         local Offset = TargetInfo.Position - CoM
         local Distance = Offset.magnitude
         if Distance <= ShieldActivationRange then
            table.insert(Targets, Offset / Distance)
         end
      end
   end

   local ShieldCount = I:Component_GetCount(SHIELDPROJECTOR)
   if ShieldCount ~= LastShieldCount then
      -- Shields got damaged or repaired, reset all timers
      LastShieldCount = ShieldCount
      ShieldActivationTimes = {}
   end

   for i=0,ShieldCount-1 do
      local BlockInfo = I:Component_GetBlockInfo(SHIELDPROJECTOR, i)
      local Forwards = BlockInfo.Forwards
      local Activate = false
      -- TODO Better way to do this instead of N x M?
      for _,Target in pairs(Targets) do
         if Vector3.Dot(Forwards, Target) >= ShieldActivationAngle then
            Activate = true
            break
         end
      end

      -- Determine last activation time
      local LastActivationTime = ShieldActivationTimes[i]
      if Activate or not LastActivationTime then
         ShieldActivationTimes[i] = Now
         LastActivationTime = Now
      end

      -- Set shield mode accordingly
      I:Component_SetIntLogic(SHIELDPROJECTOR, i, ((LastActivationTime + ShieldOffDelay) < Now) and 0 or ShieldActivationMode)
   end
end

ShieldManager = Periodic.create(UpdateRate, ShieldManager_Update)

Now = 0

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      Now = I:GetTimeSinceSpawn()
      ShieldManager:Tick(I)
   end
end
