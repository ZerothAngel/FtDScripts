--@ commonstargets commons control drivemaintainer evasion terraincheck sign clamp
-- Altitude Control module
ManualAltitudeController = DriveMaintainer.new(ManualAltitudeDriveMaintainerFacing)
HalfMaxManualAltitude = (MaxManualAltitude - MinManualAltitude) / 2

AltitudeControl_Desired = 0
AltitudeControl_Offset = 0
AltitudeControl_Min = 0
AltitudeControl_Max = 0

AltitudeControl_LastDodge = nil

AltitudeControl_CombatStart = nil

function Altitude_Control(I)
   AltitudeControl_Offset = 0
   AltitudeControl_Min = HardMinAltitude
   AltitudeControl_Max = HardMaxAltitude

   local Target = C:FirstTarget()

   local Now = C:Now()
   if Target then
      if not AltitudeControl_CombatStart then
         AltitudeControl_CombatStart = Now
      end
   else
      AltitudeControl_CombatStart = nil
   end

   local NewAltitude = DesiredAltitudeIdle
   if ManualAltitudeDriveMaintainerFacing and ManualAltitudeWhen[C:MovementMode()] then
      NewAltitude = MinManualAltitude + HalfMaxManualAltitude + ManualAltitudeController:GetThrottle(I) * HalfMaxManualAltitude
      if ManualEvasion and Target then
         AltitudeControl_Offset = CalculateEvasion(AltitudeEvasion)
      end
   elseif Target and (AltitudeControl_CombatStart + DesiredAltitudeCombatDelay) <= Now then
      NewAltitude = DesiredAltitudeCombat
      AltitudeControl_Offset = CalculateEvasion(AltitudeEvasion)
   end

   if not AbsoluteAltitude then
      -- Look ahead at terrain
      local TerrainHeight = GetTerrainHeight(I, C:Velocity(), 0, TerrainMaxAltitude)
      -- Set new absolute minimum
      AltitudeControl_Min = math.max(AltitudeControl_Min, TerrainHeight)
      -- And offset desired altitude (actually desired elevation) by terrain
      -- And constrain by relative limits
      NewAltitude = Clamp(NewAltitude + TerrainHeight, TerrainMinAltitude, TerrainMaxAltitude)
   end

   if MatchTargetAboveAltitude then
      if Target and Target.AimPoint.y >= MatchTargetAboveAltitude then
         NewAltitude = Target.AimPoint.y + MatchTargetOffset
      end
   end

   AltitudeControl_Desired = NewAltitude
end

function Altitude_Apply(_, HighPriorityOffset, NoOffset)
   -- Determine altitude based on presence of HighPriorityOffset
   local NewAltitude
   if AltitudeDodgeMode > 0 and HighPriorityOffset then
      if AltitudeDodgeMode == 2 then
         -- Most leeway
         if AltitudeControl_LastDodge then
            -- Try to keep going in the same direction
            if Sign(HighPriorityOffset) == AltitudeControl_LastDodge[1] then
               NewAltitude = C:Altitude() + AltitudeControl_LastDodge[2] * math.abs(HighPriorityOffset)
            else
               -- But reset if the AI changes direction
               AltitudeControl_LastDodge = nil
            end
         end
         if not AltitudeControl_LastDodge then
            local Above = math.max(0, AltitudeControl_Max - C:Altitude())
            local Below = math.max(0, C:Altitude() - AltitudeControl_Min)
            if Below > Above then
               NewAltitude = C:Altitude() - math.abs(HighPriorityOffset)
               AltitudeControl_LastDodge = { Sign(HighPriorityOffset), -1 }
            else
               NewAltitude = C:Altitude() + math.abs(HighPriorityOffset)
               AltitudeControl_LastDodge = { Sign(HighPriorityOffset), 1 }
            end
         end
      elseif AltitudeDodgeMode == 3 then
         -- Always upwards
         NewAltitude = C:Altitude() + math.abs(HighPriorityOffset)
      elseif AltitudeDodgeMode == 4 then
         -- Always downwards
         NewAltitude = C:Altitude() - math.abs(HighPriorityOffset)
      else
         -- As recommended
         NewAltitude = C:Altitude() + HighPriorityOffset
      end
   else
      NewAltitude = AltitudeControl_Desired + (NoOffset and 0 or AltitudeControl_Offset)
      AltitudeControl_LastDodge = nil
   end
   -- Constrain and set
   V.SetAltitude(Clamp(NewAltitude, AltitudeControl_Min, AltitudeControl_Max))
end
