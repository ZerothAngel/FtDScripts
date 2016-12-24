--@ commons manualcontroller evasion terraincheck
-- Altitude Control module
ManualAltitudeController = ManualController.create(ManualAltitudeDriveMaintainerFacing)
HalfMaxManualAltitude = MaxManualAltitude / 2

DesiredControlAltitude = 0

function Altitude_Control(I)
   local NewAltitude
   if ManualAltitudeDriveMaintainerFacing and ManualAltitudeWhen[I.AIMode] then
      NewAltitude = HalfMaxManualAltitude + ManualAltitudeController:GetReading(I) * HalfMaxManualAltitude
   else
      if C:FirstTarget() then
         NewAltitude = CalculateEvasion(Evasion, DesiredAltitudeCombat)
      else
         NewAltitude = DesiredAltitudeIdle
      end
   end

   if not AbsoluteAltitude then
      -- Look ahead at the terrain, but don't fly lower than sea level
      local Height = GetTerrainHeight(I, C:Velocity(), 0, MaxAltitude)
      NewAltitude = NewAltitude + Height
   end

   DesiredControlAltitude = NewAltitude
end
