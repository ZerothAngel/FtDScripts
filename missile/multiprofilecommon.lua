--@ commonsweapons missiledriver weapontypes
-- Multi profile module (common)

GuidanceInfos = {}
-- Weapon slot to index (into GuidanceInfos) mapping
MultiProfileMCMap = {}
-- Custom name to index (into GuidanceInfos) mapping
MultiProfileMCNameMap = {}
-- Flag to enable scanning missile controllers (kinda expensive)
MultiProfileScanMCs = false

-- Pre-process MissileProfiles, fill out GuidanceInfos
function MultiProfile_Init(DefaultMissileClass, MissileClassMap)
   for i,MP in ipairs(MissileProfiles) do
      local MissileClass = MP.Class and MissileClassMap[MP.Class] or DefaultMissileClass
      local GuidanceInfo = {
         -- Create missile guidance instance
         Controller = MissileClass.new(MP.Config),
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
            MultiProfileMCMap[WeaponSlot] = i
            MultiProfileScanMCs = true
         end
      end
      local Name = MP.SelectBy.Name
      if Name then
         -- First one using this name wins
         if not MultiProfileMCNameMap[Name] then
            MultiProfileMCNameMap[Name] = i
            MultiProfileScanMCs = true
         end
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
      -- See if any profiles using weapon slot/name selection match
      for _,MC in pairs(MultiProfileMCs) do
         -- Can only match if transceiver & MC are on same subconstruct
         if BlockInfo.SubConstructIdentifier == MC.SubConstructId then
            -- See if weapon slot yields a profile
            local SelectedIndex = MultiProfileMCMap[MC.Slot]
            if SelectedIndex then return SelectedIndex end
            -- Then try name
            SelectedIndex = MultiProfileMCNameMap[MC:CustomName(I)]
            if SelectedIndex then return SelectedIndex end
         end
      end

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
