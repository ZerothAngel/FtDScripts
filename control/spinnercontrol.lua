--@ sign
--# As of 2.1, this module only handles dediblades. FIXME?
--# The only dependent module is dediblademaintainer.
-- SpinnerControl implementation
SpinnerControl = {}

-- Note: Axis should be a unit vector depicting the positive direction
-- Typically Vector3.up, Vector3.forward, etc.
function SpinnerControl.new(Axis, AlwaysUp)
   local self = {}

   self.Axis = Axis
   self.AlwaysUp = AlwaysUp
   self.LastSpinnerCount = 0
   self.Spinners = {}

   self.Classify = SpinnerControl.Classify
   self.SetSpeed = SpinnerControl.SetSpeed

   return self
end

-- Classify and gather spinners on the construct that contribute thrust
-- along the desired axis. Should be called per Update.
-- (Assumption is that damage changes indices...)
function SpinnerControl:Classify(I)
   local SpinnerCount = I:GetDedibladeCount()
   -- If the count hasn't changed since last check, do nothing.
   if SpinnerCount == self.LastSpinnerCount then return end

   self.LastSpinnerCount = SpinnerCount
   self.Spinners = {}

   local AlwaysUp,Axis = self.AlwaysUp,self.Axis
   for i = 0,SpinnerCount-1 do
      local Info = I:GetDedibladeInfo(i)
      local DotZ = Vector3.Dot(Info.LocalRotation * Vector3.up, Axis)
      local UpSign = Sign(DotZ, 0, .001)
      if UpSign ~= 0 then
         local Spinner = {
            Index = i,
            Sign = AlwaysUp and 1 or UpSign,
         }
         table.insert(self.Spinners, Spinner)
      end
   end
end

-- Sets spinner speed, Speed can be -30 to 30 (radians/second)
function SpinnerControl:SetSpeed(I, Speed)
   for _,Spinner in pairs(self.Spinners) do
      I:SetDedibladeContinuousSpeed(Spinner.Index, Speed * Spinner.Sign)
   end
end
