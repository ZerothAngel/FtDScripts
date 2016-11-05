-- SpinnerControl implementation
SpinnerControl = {}

-- Note: Axis should be a unit vector depicting the positive direction
-- Typically Vector3.up, Vector3.forward, etc.
function SpinnerControl.create(Axis, UseSpinners, UseDediBlades, AlwaysUp)
   local self = {}

   self.Axis = Axis
   self.UseSpinners = UseSpinners
   self.UseDediBlades = UseDediBlades
   self.AlwaysUp = AlwaysUp
   self.LastSpinnerCount = 0
   self.Spinners = {}

   if UseSpinners or UseDediBlades then
      self.Classify = SpinnerControl.Classify
   else
      -- Not using spinners at all, so just make Classify do nothing
      self.Classify = function (_, _) end
   end
   self.SetSpeed = SpinnerControl.SetSpeed

   return self
end

-- Classify and gather spinners on the construct that contribute thrust
-- along the desired axis. Should be called per Update.
-- (Assumption is that damage changes indices...)
function SpinnerControl:Classify(I)
   local SpinnerCount = I:GetSpinnerCount()
   -- If the count hasn't changed since last check, do nothing.
   if SpinnerCount == self.LastSpinnerCount then return end

   self.LastSpinnerCount = SpinnerCount
   self.Spinners = {}

   local UseSpinners,UseDediBlades,AlwaysUp,Axis = self.UseSpinners,self.UseDediBlades,self.AlwaysUp,self.Axis
   for i = 0,SpinnerCount-1 do
      local IsDedi = I:IsSpinnerDedicatedHelispinner(i)
      if ((UseSpinners and not IsDedi) or
          (UseDediBlades and IsDedi)) then
         local Info = I:GetSpinnerInfo(i)
         local DotZ = Vector3.Dot(Info.LocalRotation * Vector3.up,
                                  Axis)
         if math.abs(DotZ) > 0.001 then
            local Spinner = {
               Index = i,
               Sign = AlwaysUp and 1 or Mathf.Sign(DotZ),
            }
            table.insert(self.Spinners, Spinner)
         end
      end
   end
end

-- Sets spinner speed, Speed can be -30 to 30 (radians/second)
function SpinnerControl:SetSpeed(I, Speed)
   for _,Spinner in pairs(self.Spinners) do
      I:SetSpinnerContinuousSpeed(Spinner.Index, Speed * Spinner.Sign)
   end
end
