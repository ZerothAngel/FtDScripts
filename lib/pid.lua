--@ commons
-- PID implementation
PID = {}

function PID.new(Config, Min, Max)
   local self = {}
   self.Kp = Config.Kp
   if Config.Ti ~= 0 then
      self.Ki = Config.Kp / Config.Ti
   else
      self.Ki = 0
   end
   self.Kd = Config.Kp * Config.Td
   self.Integral = 0.0
   self.LastError = 0.0
   self.Min = Min
   self.Max = Max

   -- Due to lack of setmetatable
   self.Control = PID.FirstControl

   return self
end

function PID:Control(Error)
   local Now = C:Now()
   local dt = Now - self.LastTime
   local Integral = self.Integral + Error * dt
   local Derivative = (Error - self.LastError) / dt
   self.LastError = Error
   self.LastTime = Now

   local CV = (self.Kp * Error) +
      (self.Ki * Integral) +
      (self.Kd * Derivative)

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

function PID:FirstControl(_)
   -- Call the real one next time
   self.Control = PID.Control
   -- Just set LastTime and return 0 for now
   self.LastTime = C:Now()
   return 0
end
