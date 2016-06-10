-- PID implementation
PID = {}

function PID.create(Kp, Ki, Kd, min, max)
   local self = {}
   local dt = 1.0 / 40.0
   self.Kp = Kp
   self.Kidt = Ki * dt
   self.Kddt = Kd / dt
   self.integral = 0.0
   self.lastError = 0.0
   self.min = min
   self.max = max

   -- Due to lack of setmetatable
   self.Reset = PID.Reset
   self.Control = PID.Control

   return self
end

function PID:Reset()
   self.integral = 0.0
   self.lastError = 0.0
end

function PID:Control(error)
   local integral = self.integral + error
   local derivative = error - self.lastError
   self.lastError = error

   local CV = (self.Kp * error) +
      (self.Kidt * integral) +
      (self.Kddt * derivative)

   -- Windup prevention
   if CV > self.max then
      if integral <= self.integral then self.integral = integral end
      return self.max
   elseif CV < self.min then
      if integral >= self.integral then self.integral = integral end
      return self.min
   end

   self.integral = integral
   return CV
end
