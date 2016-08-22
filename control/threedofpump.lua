--@ api sign pid
-- 3DoF Pump module (Altitude, Pitch, Roll)
AltitudePID = PID.create(AltitudePIDConfig, -10, 10)
PitchPID = PID.create(PitchPIDConfig, -10, 10)
RollPID = PID.create(RollPIDConfig, -10, 10)

DesiredAltitude = 0
DesiredPitch = 0

LastPumpCount = 0
PumpInfos = {}

function SetAltitude(Alt)
   DesiredAltitude = Alt
end

function AdjustAltitude(Delta)
   DesiredAltitude = Altitude + Delta
end

function SetPitch(Angle)
   DesiredPitch = Angle
end

function ClassifyPumps(I)
   local PumpCount = I:Component_GetCount(PumpType)
   if PumpCount ~= LastPumpCount then
      PumpInfos = {}
      LastPumpCount = PumpCount

      for i = 0,PumpCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PumpType, i)
         local CoMOffset = BlockInfo.LocalPositionRelativeToCom
         local Info = {
            RollSign = -1 * Sign(CoMOffset.x),
            PitchSign = Sign(CoMOffset.z),
         }
         table.insert(PumpInfos, Info)
      end
   end
end
      
function ThreeDoFPump_Update(I)
   local AltitudeCV = AltitudePID:Control(DesiredAltitude - Altitude)
   local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - Pitch) or 0
   local RollCV = ControlRoll and RollPID:Control(-Roll) or 0

   ClassifyPumps(I)

   for index,Info in pairs(PumpInfos) do
      local Output = AltitudeCV + PitchCV * Info.PitchSign + RollCV * Info.RollSign
      Output = math.max(0, math.min(10, Output))
      I:Component_SetFloatLogic(PumpType, index, Output / 10)
   end
end
