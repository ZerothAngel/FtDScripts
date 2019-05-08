--@ commonsweapons missiledriver weapontypes
-- Multi profile module (common)

GuidanceInfos = {}
-- Map of custom names to GuidanceInfos index
MultiProfileNameMap = {}

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
      local Name = MP.SelectBy.Name
      if Name then
         -- First one using this name wins
         if not MultiProfileNameMap[Name] then
            MultiProfileNameMap[Name] = i
         end
      end
   end
end

-- Returns index into GuidanceInfos
function SelectGuidance(I, TransceiverIndex)
   local BlockInfo = I:GetLuaTransceiverInfo(TransceiverIndex)
   local NameIndex = MultiProfileNameMap[BlockInfo.CustomName]
   if NameIndex then return NameIndex end

   -- Otherwise, fall through...

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
   MissileDriver_Update(I, GuidanceInfos, SelectGuidance)
end
