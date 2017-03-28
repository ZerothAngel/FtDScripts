--@ commons manualcontroller evasion terraincheck
-- Altitude Control module
ManualAltitudeController = ManualController.create(ManualAltitudeDriveMaintainerFacing)
HalfMaxManualAltitude = (MaxManualAltitude - MinManualAltitude) / 2

DesiredControlAltitude = 0
ControlAltitudeOffset = 0

function Altitude_Control(I)
   ControlAltitudeOffset = 0

   local NewAltitude
   if ManualAltitudeDriveMaintainerFacing and ManualAltitudeWhen[I.AIMode] then
      NewAltitude = MinManualAltitude + HalfMaxManualAltitude + ManualAltitudeController:GetReading(I) * HalfMaxManualAltitude
      if ManualEvasion and C:FirstTarget() then
         ControlAltitudeOffset = CalculateEvasion(Evasion)
      end
   else
      if C:FirstTarget() then
         NewAltitude = DesiredAltitudeCombat
         ControlAltitudeOffset = CalculateEvasion(Evasion)
      else
         NewAltitude = DesiredAltitudeIdle
      end
   end

   if not AbsoluteAltitude then
      -- Look ahead at terrain and offset by highest terrain seen
      local Height = GetTerrainHeight(I, C:Velocity(), 0, MaxLookAheadAltitude)
      NewAltitude = NewAltitude + Height
   end

   DesiredControlAltitude = NewAltitude
end
