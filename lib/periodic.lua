-- Periodic implementation
Periodic = {}

function Periodic.create(Period, Function)
   local self = {}

   self.Ticks = 0
   self.Period = Period
   self.Function = Function

   self.Tick = Periodic.Tick

   return self
end

function Periodic:Tick(I)
   self.Ticks = self.Ticks + 1
   if self.Ticks >= self.Period then
      self.Period = 0
      self.Function(I)
   end
end
