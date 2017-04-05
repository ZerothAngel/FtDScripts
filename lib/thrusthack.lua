--@ componenttypes
-- Thrust hack via drive maintainer
ThrustHack = {}

function ThrustHack.create(Direction)
   local self = {}

   if Direction then
      self.Direction = Direction
      self.LastDriveMaintainerCount = 0
      self.DriveMaintainerIndex = nil

      self.SetThrottle = ThrustHack.SetThrottle
   else
      -- Dummy method for safety. Better to just not call.
      self.SetThrottle = function (_, _, _) end
   end

   return self
end

function ThrustHack:SetThrottle(I, Throttle)
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

   if DriveMaintainerIndex then
      I:Component_SetFloatLogic(DRIVEMAINTAINER, DriveMaintainerIndex, Throttle)
   end
end
