--@ commons componenttypes sign pid clamp
-- 3DoF Pump module (Altitude, Pitch, Roll)
ThreeDoFPump_AltitudePID = PID.new(ThreeDoFPumpPIDConfig.Altitude, -10, 10)
ThreeDoFPump_PitchPID = PID.new(ThreeDoFPumpPIDConfig.Pitch, -10, 10)
ThreeDoFPump_RollPID = PID.new(ThreeDoFPumpPIDConfig.Roll, -10, 10)

ThreeDoFPump_DesiredAltitude = 0
ThreeDoFPump_DesiredPitch = 0
ThreeDoFPump_DesiredRoll = 0

ThreeDoFPump_LastPumpCount = 0
ThreeDoFPump_PumpInfos = {}

ThreeDoFPump = {}

function ThreeDoFPump.SetAltitude(Alt)
   ThreeDoFPump_DesiredAltitude = Alt
end

function ThreeDoFPump.SetPitch(Angle)
   ThreeDoFPump_DesiredPitch = Angle
end

function ThreeDoFPump.SetRoll(Angle)
   ThreeDoFPump_DesiredRoll = Angle
end

function ThreeDoFPump_ClassifyPumps(I)
   local PumpCount = I:Component_GetCount(PumpType)
   if PumpCount ~= ThreeDoFPump_LastPumpCount then
      ThreeDoFPump_PumpInfos = {}
      ThreeDoFPump_LastPumpCount = PumpCount

      for i = 0,PumpCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PumpType, i)
         local CoMOffset = BlockInfo.LocalPositionRelativeToCom
         local Info = {
            RollSign = -1 * Sign(CoMOffset.x),
            PitchSign = Sign(CoMOffset.z),
         }
         table.insert(ThreeDoFPump_PumpInfos, Info)
      end
   end
end
      
function ThreeDoFPump.Update(I)
   local AltitudeCV = ThreeDoFPump_AltitudePID:Control(ThreeDoFPump_DesiredAltitude - C:Altitude())
   local PitchCV = ControlPitch and ThreeDoFPump_PitchPID:Control(ThreeDoFPump_DesiredPitch - C:Pitch()) or 0
   local RollCV = ControlRoll and ThreeDoFPump_RollPID:Control(ThreeDoFPump_DesiredRoll - C:Roll()) or 0

   ThreeDoFPump_ClassifyPumps(I)

   for index,Info in pairs(ThreeDoFPump_PumpInfos) do
      local Output = Clamp(AltitudeCV + PitchCV * Info.PitchSign + RollCV * Info.RollSign, 0, 10)
      I:Component_SetFloatLogic(PumpType, index, Output / 10)
   end
end
