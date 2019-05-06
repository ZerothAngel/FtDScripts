--@ namedcomponent componenttypes
-- Drive maintainer module
DriveMaintainer = {}

function DriveMaintainer.new(Name)
   local self = {}

   if Name then
      self.Name = Name
      self.NamedComponent = NamedComponent.new(DRIVEMAINTAINER)
      self.LastReading = 0

      self.GetThrottle = DriveMaintainer.GetThrottle
      self.SetThrottle = DriveMaintainer.SetThrottle
   else
      -- Dummy methods for safety. Better to have logic to just not call them.
      self.GetThrottle = function (_, _) return 0 end
      self.SetThrottle = function (_, _, _) end
   end

   return self
end

function DriveMaintainer:GetThrottle(I)
   local Index = self.NamedComponent:GetIndex(I, self.Name)
   if Index >= 0 then
      -- Update LastReading if we actually have a drive maintainer
      self.LastReading = I:Component_GetFloatLogic(DRIVEMAINTAINER, Index)
   end
   return self.LastReading
end

function DriveMaintainer:SetThrottle(I, Throttle)
   local Index = self.NamedComponent:GetIndex(I, self.Name)
   if Index >= 0 then
      I:Component_SetFloatLogic(DRIVEMAINTAINER, Index, Throttle)
   end
end
