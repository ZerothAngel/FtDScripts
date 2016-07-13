-- PID implementation
PID = {}

function PID.create(Config, Min, Max, UpdateRate)
   local self = {}
   if not UpdateRate then UpdateRate = 1 end
   local dt = UpdateRate / 40
   self.Kp = Config.Kp
   if Config.Ti ~= 0 then
      self.Kidt = Config.Kp * dt / Config.Ti
   else
      self.Kidt = 0
   end
   self.Kddt = Config.Kp * Config.Td / dt
   self.Integral = 0.0
   self.LastError = 0.0
   self.Min = Min
   self.Max = Max

   -- Due to lack of setmetatable
   self.Control = PID.Control

   return self
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
