--@ commons sign pid
-- 3DoF Jet module (Altitude, Pitch, Roll)
AltitudePID = PID.create(AltitudePIDConfig, -10, 10)
PitchPID = PID.create(PitchPIDConfig, -10, 10)
RollPID = PID.create(RollPIDConfig, -10, 10)

DesiredAltitude = 0
DesiredPitch = 0
DesiredRoll = 0

ThreeDoFJet_LastPropulsionCount = 0
ThreeDoFJet_PropulsionInfos = {}

function SetAltitude(Alt)
   DesiredAltitude = Alt
end

function AdjustAltitude(Delta) -- luacheck: ignore 131
   DesiredAltitude = C:Altitude() + Delta
end

function SetPitch(Angle) -- luacheck: ignore 131
   DesiredPitch = Angle
end

function SetRoll(Angle) -- luacheck: ignore 131
   DesiredRoll = Angle
end

function ThreeDoFJet_Classify(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= ThreeDoFJet_LastPropulsionCount then
      ThreeDoFJet_PropulsionInfos = {}
      ThreeDoFJet_LastPropulsionCount = PropulsionCount

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         local LocalForwards = BlockInfo.LocalForwards
         if math.abs(LocalForwards.y) > .001 then
            local CoMOffset = BlockInfo.LocalPositionRelativeToCom
            local UpSign = Sign(LocalForwards.y)
            local Info = {
               Index = i,
               UpSign = UpSign,
               PitchSign = ControlPitch and (Sign(CoMOffset.z) * UpSign) or 0,
               RollSign = ControlRoll and (Sign(CoMOffset.x) * UpSign) or 0,
            }
            table.insert(ThreeDoFJet_PropulsionInfos, Info)
         end
      end
   end
end

function ThreeDoFJet_Update(I)
   local AltitudeCV = AltitudePID:Control(DesiredAltitude - C:Altitude())
   local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - C:Pitch()) or 0
   local RollCV = ControlRoll and RollPID:Control(DesiredRoll - C:Roll()) or 0

   ThreeDoFJet_Classify(I)

   -- Blip upward and downward thrusters
   I:RequestThrustControl(4)
   I:RequestThrustControl(5)

   -- And set drive fraction accordingly
   for _,Info in pairs(ThreeDoFJet_PropulsionInfos) do
      -- Sum up inputs and constrain
      local Output = AltitudeCV * Info.UpSign + PitchCV * Info.PitchSign + RollCV * Info.RollSign
      Output = math.max(0, math.min(10, Output))
      I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 10)
   end
end
