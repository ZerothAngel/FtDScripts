-- EventDriver implementation
EventDriver = {}

function EventDriver.create()
   local self = {}

   self.Ticks = 0
   self.Events = {}

   self.Schedule = EventDriver.Schedule
   self.Tick = EventDriver.Tick

   return self
end

function EventDriver:Schedule(Delay, Function)
   local At = self.Ticks + Delay
   local Event = {
      At = At,
      Function = Function,
   }

   local Events = self.Events
   -- Insertion sort
   for i,e in ipairs(Events) do
      if At < e.At then
         -- Insert before this one
         table.insert(Events, i, Event)
         return
      end
   end

   -- If we get here, just insert at the end
   table.insert(Events, Event)
end

function EventDriver:Tick(I)
   local Ticks = self.Ticks + 1
   self.Ticks = Ticks

   local Events = self.Events

   local Event = Events[1]
   while Event do
      if Event.At <= Ticks then
         Event.Function(I)
      else
         break
      end

      table.remove(Events, 1)
      Event = Events[1]
   end
end
