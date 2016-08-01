-- Periodic implementation
Periodic = {}

function Periodic.create(Period, Function, Start)
   local self = {}

   if Period then
      self.Period = Period / 40 - .0125 -- Shorten by half a frame
      self.Function = Function
      self.Offset = Start and (Start / 40) or 0

      self.Tick = Periodic.FirstTick
   else
      -- If Period is nil, Tick does nothing
      self.Tick = function (self, I) end
   end

   return self
end

function Periodic:Tick(I)
   if Now >= self.Next then
      self.Next = Now + self.Period
      self.Function(I)
   end
end

function Periodic:FirstTick(I)
   -- Because Now isn't valid until... now.
   self.Next = Now + self.Offset
   self.Tick = Periodic.Tick
   self:Tick(I)
end
