--@ api
-- ManualController implementation
ManualController = {}

function ManualController.create(Direction)
   local self = {}

   if Direction then
      self.Direction = Direction
      self.LastDriveMaintainerCount = 0
      self.DriveMaintainerIndex = nil
      self.LastReading = 0

      self.GetReading = ManualController.GetReading
   else
      -- No Direction, no manual control
      -- Set GetReading to dummy function
      -- (it's best if it isn't called at all...)
      self.GetReading = function (_, _) return 0 end
   end

   return self
end

function ManualController:GetReading(I)
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

      if not DriveMaintainerIndex then
         -- Still don't have one, just return last reading
         return self.LastReading
      end
   end

   self.LastReading = I:Component_GetFloatLogic(DRIVEMAINTAINER, DriveMaintainerIndex)
   return self.LastReading
end
