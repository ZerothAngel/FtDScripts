--@ api sign pid manualcontroller firstrun
--@ gettargetpositioninfo terraincheck
-- 3DoF Spinner module (Altitude, Pitch, Roll)
AltitudePID = PID.create(AltitudePIDConfig, -30, 30)
PitchPID = PID.create(PitchPIDConfig, -30, 30)
RollPID = PID.create(RollPIDConfig, -30, 30)

PerlinOffset = 0

DesiredAltitude = 0

ManualAltitudeController = ManualController.create(ManualAltitudeDriveMaintainerFacing)
HalfMaxManualAltitude = MaxManualAltitude / 2

LastSpinnerCount = 0
Spinners = {}

function ThreeDoFSpinner_FirstRun(I)
   PerlinOffset = 1000.0 * math.random()
end
AddFirstRun(ThreeDoFSpinner_FirstRun)

function ThreeDoFSpinner_ClassifySpinners(I)
   local SpinnerCount = I:GetSpinnerCount()
   if SpinnerCount ~= LastSpinnerCount then
      LastSpinnerCount = SpinnerCount
      Spinners = {}

      for i = 0,SpinnerCount-1 do
         local IsDedi = I:IsSpinnerDedicatedHelispinner(i)
         if IsDedi then -- TODO regular spinner support
            local Info = I:GetSpinnerInfo(i)
            local DotZ = (Info.LocalRotation * Vector3.up).y
            if math.abs(DotZ) > .001 then
               local CoMOffset = Info.LocalPositionRelativeToCom
               local UpSign = DediBladesAlwaysUp and 1 or Sign(DotZ)
               local Spinner = {
                  Index = i,
                  AltitudeSign = UpSign,
                  PitchSign = UpSign * Sign(CoMOffset.z),
                  RollSign = UpSign * Sign(CoMOffset.x),
               }
               table.insert(Spinners, Spinner)
            end
         end
      end
   end
end

function ThreeDoFSpinner_Control(I)
   if ManualAltitudeDriveMaintainerFacing and ManualAltitudeWhen[I.AIMode] then
      DesiredAltitude = HalfMaxManualAltitude + ManualAltitudeController:GetReading(I) * HalfMaxManualAltitude
   else
      if GetTargetPositionInfo(I) then
         DesiredAltitude = DesiredAltitudeCombat

         -- Modify by Evasion, if set
         if Evasion then
            DesiredAltitude = DesiredAltitude + Evasion[1] * (2.0 * Mathf.PerlinNoise(Evasion[2] * Now, PerlinOffset) - 1.0)
         end
      else
         DesiredAltitude = DesiredAltitudeIdle
      end
   end

   if not AbsoluteAltitude then
      -- Look ahead at the terrain, but don't fly lower than sea level
      local Velocity = I:GetVelocityVector()
      local Height = GetTerrainHeight(I, Velocity, 0, MaxAltitude)
      DesiredAltitude = DesiredAltitude + Height
   end
end

function ThreeDoFSpinner_Update(I)
   local AltitudeCV = AltitudePID:Control(DesiredAltitude - Altitude)
   local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - Pitch) or 0
   local RollCV = ControlRoll and RollPID:Control(-Roll) or 0

   ThreeDoFSpinner_ClassifySpinners(I)

   for index,Info in pairs(Spinners) do
      local Output = AltitudeCV * Info.AltitudeSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign
      Output = math.max(-30, math.min(30, Output))
      I:SetSpinnerContinuousSpeed(Info.Index, Output)
   end
end
