--@ api
-- ShieldManager module
-- Re-do in terms of cosine
ShieldActivationAngle = math.cos(math.rad(ShieldActivationAngle))

LastShieldCount = 0
ShieldActivationTimes = {}

function ShieldManager_SetShield(I, Index, State)
   if ShieldActivationMode then
      -- Set to configured mode or turn off
      I:Component_SetIntLogic(SHIELDPROJECTOR, Index, State and ShieldActivationMode or 0)
   else
      -- Scale strength up or down
      local Current = I:Component_GetFloatLogic(SHIELDPROJECTOR, Index)
      -- Only change if different
      local Scale = 16 -- Power of 2 that's >10
      if Current < 1 and State then
         I:Component_SetFloatLogic(SHIELDPROJECTOR, Index, Current * Scale)
      elseif Current >= 1 and not State then
         I:Component_SetFloatLogic(SHIELDPROJECTOR, Index, Current / Scale)
      end
   end
end

function ShieldManager_Update(I)
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
      local ShieldOn = (LastActivationTime + ShieldOffDelay) >= Now
      ShieldManager_SetShield(I, i, ShieldOn)
   end
end

function ShieldManager_Disable(I)
   for i=0,I:Component_GetCount(SHIELDPROJECTOR) do
      ShieldManager_SetShield(I, i, false)
   end
end

function ShieldManager_Control(I)
   if I:IsDocked() then
      ShieldManager_Disable(I)
   else
      ShieldManager_Update(I)
   end
end
