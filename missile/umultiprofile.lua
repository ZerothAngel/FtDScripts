--@ commonsweapons missiledriver unifiedmissile weapontypes
-- Multi profile module (unifiedmissile)

GuidanceInfos = {}
-- Weapon slot to index (into GuidanceInfos) mapping
MultiProfileMCMap = {}
-- Flag to enable scanning missile controllers (kinda expensive)
MultiProfileScanMCs = false

-- Pre-process MissileProfiles, fill out GuidanceInfos
for i,MP in ipairs(MissileProfiles) do
   local GuidanceInfo = {
      -- Create UnifiedMissile instance
      Controller = UnifiedMissile.new(MP.Config),
      -- Set limits
      MinAltitude = MP.Limits.MinAltitude,
      MaxAltitude = MP.Limits.MaxAltitude,
      -- Square ranges
      MinRange = MP.Limits.MinRange^2,
      MaxRange = MP.Limits.MaxRange^2,
      -- Extra info to make things easier
      Vertical = MP.SelectBy.Vertical,
      Direction = MP.SelectBy.Direction,
      WeaponSlot = MP.FireWeaponSlot,
      TargetSelector = MP.TargetSelector,
   }
   table.insert(GuidanceInfos, GuidanceInfo)
   local WeaponSlot = MP.SelectBy.WeaponSlot
   if WeaponSlot then
      -- First profile using a weapon slot wins
      if not MultiProfileMCMap[WeaponSlot] then
         MultiProfileMCMap[WeaponSlot] = { i, MP.SelectBy.Distance^2 }
         MultiProfileScanMCs = true
      end
   end
end

-- Cache of missile controllers
MultiProfileMCs = nil

-- Returns index into GuidanceInfos
function SelectGuidance(I, TransceiverIndex)
   local BlockInfo = I:GetLuaTransceiverInfo(TransceiverIndex)

   if MultiProfileScanMCs then
      -- Build cache of missile controllers, if needed
      if not MultiProfileMCs then
         MultiProfileMCs = {}
         for _,Weapon in pairs(C:WeaponControllers()) do
            if Weapon.Type == MISSILECONTROL then
               table.insert(MultiProfileMCs, Weapon)
            end
         end
      end
      -- See if any profiles using weapon slot/distance selection match
      local Closest,SelectedIndex = math.huge,nil
      for _,MC in pairs(MultiProfileMCs) do
         local MCMap = MultiProfileMCMap[MC.Slot]
         if MCMap then
            local Index,BlockRange = unpack(MCMap)
            local Distance = (BlockInfo.Position - MC.Position).sqrMagnitude
            if Distance <= BlockRange and Distance < Closest then
               Closest = Distance
               SelectedIndex = Index
            end
         end
      end

      if SelectedIndex then return SelectedIndex end
      -- Otherwise fall through
   end

   -- Selection by orientation or direction
   for Index,GuidanceInfo in ipairs(GuidanceInfos) do
      local Direction = GuidanceInfo.Direction
      if Direction then
         for _,Dir in pairs(Direction) do
            if Vector3.Dot(BlockInfo.LocalForwards, Dir) > .001 then
               return Index
            end
         end
      else
         local Vertical = GuidanceInfo.Vertical
         -- Explicitly match true/false because it can be nil
         if Vertical == true and math.abs(BlockInfo.LocalForwards.y) > .001 then
            return Index
         elseif Vertical == false and math.abs(BlockInfo.LocalForwards.y) <= .001 then
            return Index
         end
      end
   end

   -- /sad trombone
   return 1
end

-- Main update loop
function MissileMain_Update(I)
   -- Clear cache before every update to avoid trouble
   MultiProfileMCs = nil

   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end
