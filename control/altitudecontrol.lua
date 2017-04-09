--@ commons manualcontroller evasion terraincheck
-- Altitude Control module
ManualAltitudeController = ManualController.create(ManualAltitudeDriveMaintainerFacing)
HalfMaxManualAltitude = (MaxManualAltitude - MinManualAltitude) / 2

AltitudeControl_Desired = 0
AltitudeControl_Offset = 0
AltitudeControl_Min = 0
AltitudeControl_Max = 0

function Altitude_Control(I)
   AltitudeControl_Offset = 0
   AltitudeControl_Min = HardMinAltitude
   AltitudeControl_Max = HardMaxAltitude

   local NewAltitude
   if ManualAltitudeDriveMaintainerFacing and ManualAltitudeWhen[I.AIMode] then
      NewAltitude = MinManualAltitude + HalfMaxManualAltitude + ManualAltitudeController:GetReading(I) * HalfMaxManualAltitude
      if ManualEvasion and C:FirstTarget() then
         AltitudeControl_Offset = CalculateEvasion(AltitudeEvasion)
      end
   else
      if C:FirstTarget() then
         NewAltitude = DesiredAltitudeCombat
         AltitudeControl_Offset = CalculateEvasion(AltitudeEvasion)
      else
         NewAltitude = DesiredAltitudeIdle
      end
   end

   if not AbsoluteAltitude then
      -- Look ahead at terrain
      local TerrainHeight = GetTerrainHeight(I, C:Velocity(), 0, TerrainMaxAltitude)
      -- Set new absolute minimum
      AltitudeControl_Min = math.max(AltitudeControl_Min, TerrainHeight)
      -- And offset desired altitude (actually desired elevation) by terrain
      NewAltitude = NewAltitude + TerrainHeight
      -- And constrain by relative limits
      NewAltitude = math.max(TerrainMinAltitude, math.min(TerrainMaxAltitude, NewAltitude))
   end

   AltitudeControl_Desired = NewAltitude
end

function Altitude_Apply(_, HighPriorityOffset, NoOffset)
   -- Determine altitude based on presence of HighPriorityOffset
   local NewAltitude
   if AltitudeDodging and HighPriorityOffset then
      NewAltitude = C:Altitude() + HighPriorityOffset
   else
      NewAltitude = AltitudeControl_Desired + (NoOffset and 0 or AltitudeControl_Offset)
   end
   -- Constrain and set
   SetAltitude(math.max(AltitudeControl_Min, math.min(AltitudeControl_Max, NewAltitude)))
end
