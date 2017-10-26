--@ componenttypes
-- Drive maintainer module
DriveMaintainer = {}

function DriveMaintainer.create(Direction)
   local self = {}

   if Direction then
      self.Direction = Direction
      self.LastDriveMaintainerCount = 0
      self.DriveMaintainerIndex = nil
      self.LastReading = 0

      -- This is private, shouldn't be called outside this module
      self.Resolve = DriveMaintainer.Resolve
      -- Public methods
      self.GetThrottle = DriveMaintainer.GetThrottle
      self.SetThrottle = DriveMaintainer.SetThrottle
   else
      -- Dummy methods for safety. Better to have logic to just not call them.
      self.GetThrottle = function (_, _) return 0 end
      self.SetThrottle = function (_, _, _) end
   end

   return self
end

function DriveMaintainer:Resolve(I)
   local DriveMaintainerCount = I:Component_GetCount(DRIVEMAINTAINER)
   if DriveMaintainerCount ~= self.LastDriveMaintainerCount then
      -- Clear cached index
      self.DriveMaintainerIndex = nil
      self.LastDriveMaintainerCount = DriveMaintainerCount
   end

   local DriveMaintainerIndex = self.DriveMaintainerIndex
   if not DriveMaintainerIndex then
      -- Look for the first one facing the direction we want
      local Direction = self.Direction
      for i = 0,DriveMaintainerCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(DRIVEMAINTAINER, i)
         if Vector3.Dot(BlockInfo.LocalForwards, Direction) > 0.001 then
            DriveMaintainerIndex = i
            self.DriveMaintainerIndex = DriveMaintainerIndex
            break
         end
      end
   end

   return DriveMaintainerIndex
end

function DriveMaintainer:GetThrottle(I)
   local DriveMaintainerIndex = self:Resolve(I)
   if DriveMaintainerIndex then
      -- Update LastReading if we actually have a drive maintainer
      self.LastReading = I:Component_GetFloatLogic(DRIVEMAINTAINER, DriveMaintainerIndex)
   end
   return self.LastReading
end

function DriveMaintainer:SetThrottle(I, Throttle)
   local DriveMaintainerIndex = self:Resolve(I)
   if DriveMaintainerIndex then
      I:Component_SetFloatLogic(DRIVEMAINTAINER, DriveMaintainerIndex, Throttle)
   end
end
