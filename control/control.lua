--@ commons pid clamp
-- Vehicle control module
Vehicle_ThrottlePID = PID.new(VehicleConfig.ThrottlePIDConfig, -1, 1)

if not VehicleConfig.MinimumSpeed then VehicleConfig.MinimumSpeed = 0 end

-- The one global for vehicle controls
V = {}

function Vehicle_MakeReset(Table)
   local ResetHeading,ResetThrottle,ResetPosition = Table.ResetHeading,Table.ResetThrottle,Table.ResetPosition
   function Table.Reset()
      if ResetHeading then ResetHeading() end
      if ResetThrottle then ResetThrottle() end
      if ResetPosition then ResetPosition() end
   end
end

function Vehicle_SetSpeed(Table, DesiredSpeed, CurrentSpeed) -- luacheck: ignore 131
   DesiredSpeed = math.max(VehicleConfig.MinimumSpeed, DesiredSpeed)
   if not CurrentSpeed then CurrentSpeed = C:ForwardSpeed() end
   local Error = DesiredSpeed - CurrentSpeed
   local CV = Vehicle_ThrottlePID:Control(Error)
   local Drive = Clamp(Table.GetThrottle() + CV, 0, 1)
   Table.SetThrottle(Drive)
end

function SelectAltitudeImpl(Source, Table) -- luacheck: ignore 131
   Table = Table or V
   Table.SetAltitude = Source.SetAltitude
   function Table.AdjustAltitude(Delta)
      Table.SetAltitude(C:Altitude() + Delta)
   end
end

function SelectHeadingImpl(Source, Table) -- luacheck: ignore 131
   Table = Table or V
   Table.SetHeading = Source.SetHeading
   Table.ResetHeading = Source.ResetHeading
   function Table.AdjustHeading(Bearing)
      Table.SetHeading(C:Yaw() + Bearing)
   end
   Vehicle_MakeReset(Table)
end

function SelectThrottleImpl(Source, Table) -- luacheck: ignore 131
   Table = Table or V
   Table.SetThrottle = Source.SetThrottle
   Table.GetThrottle = Source.GetThrottle
   Table.ResetThrottle = Source.ResetThrottle
   function Table.AdjustThrottle(Delta)
      Table.SetThrottle(Table.GetThrottle() + Delta)
   end
   function Table.SetSpeed(DesiredSpeed, CurrentSpeed)
      Vehicle_SetSpeed(Table, DesiredSpeed, CurrentSpeed)
   end
   Vehicle_MakeReset(Table)
end

function SelectPositionImpl(Source, Table) -- luacheck: ignore 131
   Table = Table or V
   Table.SetPosition = Source.SetPosition
   Table.ResetPosition = Source.ResetPosition
   function Table.AdjustPosition(Offset)
      Table.SetPosition(C:CoM() + Offset)
   end
   Vehicle_MakeReset(Table)
end

function SelectPitchImpl(Source, Table) -- luacheck: ignore 131
   Table = Table or V
   Table.SetPitch = Source.SetPitch
end

function SelectRollImpl(Source, Table) -- luacheck: ignore 131
   Table = Table or V
   Table.SetRoll = Source.SetRoll
end
