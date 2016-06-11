-- PID implementation
PID = {}

function PID.create(Kp, Ki, Kd, Min, Max)
   local self = {}
   local dt = 1.0 / 40.0
   self.Kp = Kp
   self.Kidt = Ki * dt
   self.Kddt = Kd / dt
   self.Integral = 0.0
   self.LastError = 0.0
   self.Min = Min
   self.Max = Max

   -- Due to lack of setmetatable
   self.Reset = PID.Reset
   self.Control = PID.Control

   return self
end

function PID:Reset()
   self.Integral = 0.0
   self.LastError = 0.0
end

function PID:Control(Error)
   local Integral = self.Integral + Error
   local Derivative = Error - self.LastError
   self.LastError = Error

   local CV = (self.Kp * Error) +
      (self.Kidt * Integral) +
      (self.Kddt * Derivative)

   -- Windup prevention
   if CV > self.Max then
      if Integral <= self.Integral then self.Integral = Integral end
      return self.Max
   elseif CV < self.Min then
      if Integral >= self.Integral then self.Integral = Integral end
      return self.Min
   end

   self.Integral = Integral
   return CV
end
