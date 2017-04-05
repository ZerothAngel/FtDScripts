--@ commons componenttypes normalizebearing sign pid thrusthack
-- 5DoF module (Yaw, Pitch, Roll, Forward/Reverse, Right/Left)
YawPID = PID.create(YawPIDConfig, -10, 10)
PitchPID = PID.create(PitchPIDConfig, -10, 10)
RollPID = PID.create(RollPIDConfig, -10, 10)
ForwardPID = PID.create(ForwardPIDConfig, -10, 10)
RightPID = PID.create(RightPIDConfig, -10, 10)

LastPropulsionCount = 0
PropulsionInfos = {}

DesiredHeading = nil
DesiredPosition = nil
DesiredPitch = 0
DesiredRoll = 0

PRThrustHackControl = ThrustHack.create(PRThrustHackDriveMaintainerFacing)
YLLThrustHackControl = ThrustHack.create(YLLThrustHackDriveMaintainerFacing)

-- Sets heading to an absolute value, 0 is north, 90 is east
function SetHeading(Heading)
   DesiredHeading = Heading % 360
end

-- Adjusts heading toward relative bearing
function AdjustHeading(Bearing)
   SetHeading(C:Yaw() + Bearing)
end

-- Resets heading so yaw will no longer be modified
function ResetHeading()
   DesiredHeading = nil
end

function SetPosition(Pos)
   -- Make copy to be safe
   DesiredPosition = Vector3(Pos.x, Pos.y, Pos.z)
end

function AdjustPosition(Offset)
   DesiredPosition = C:CoM() + Offset
end

function ResetPosition()
   DesiredPosition = nil
end

function SetPitch(Angle) -- luacheck: ignore 131
   DesiredPitch = Angle
end

function SetRoll(Angle) -- luacheck: ignore 131
   DesiredRoll = Angle
end

function FiveDoF_Reset()
   ResetHeading()
   ResetPosition()
end

function ClassifyPropulsion(I)
   local PropulsionCount = I:Component_GetCount(PROPULSION)
   if PropulsionCount ~= LastPropulsionCount then
      -- Something got damaged or repaired, clear the cache
      PropulsionInfos = {}
      LastPropulsionCount = PropulsionCount

      for i = 0,PropulsionCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(PROPULSION, i)
         local CoMOffset = BlockInfo.LocalPositionRelativeToCom
         local LocalForwards = BlockInfo.LocalForwards
         local Info = {
            Index = i,
            YawSign = 0,
            PitchSign = 0,
            RollSign = 0,
            ForwardSign = 0,
            RightSign = 0,
            IsVertical = false,
         }
         if math.abs(LocalForwards.y) > 0.001 then
            -- Vertical
            local UpSign = Sign(LocalForwards.y)
            Info.PitchSign = Sign(CoMOffset.z) * UpSign
            Info.RollSign = Sign(CoMOffset.x) * UpSign
            Info.IsVertical = true
         else
            -- Horizontal
            local RightSign = Sign(LocalForwards.x)
            local ZSign = Sign(CoMOffset.z)
            Info.YawSign = RightSign * ZSign
            Info.ForwardSign = Sign(LocalForwards.z)
            Info.RightSign = RightSign
         end
         table.insert(PropulsionInfos, Info)
      end
   end
end

function FiveDoF_Update(I)
   local YawCV = DesiredHeading and YawPID:Control(NormalizeBearing(DesiredHeading - C:Yaw())) or 0
   local PitchCV = PitchPID:Control(DesiredPitch - C:Pitch())
   local RollCV = RollPID:Control(DesiredRoll - C:Roll())

   local ForwardCV,RightCV = 0,0
   if DesiredPosition then
      local Offset = DesiredPosition - C:CoM()
      local ZProj = Vector3.Dot(Offset, C:ForwardVector())
      local XProj = Vector3.Dot(Offset, C:RightVector())
      ForwardCV = ForwardPID:Control(ZProj)
      RightCV = RightPID:Control(XProj)
   end

   ClassifyPropulsion(I)

   if DesiredHeading or DesiredPosition then
      -- Blip horizontal thrusters
      if not YLLThrustHackDriveMaintainerFacing then
         for i = 0,3 do
            I:RequestThrustControl(i)
         end
      else
         YLLThrustHackControl:SetThrottle(I, 1)
      end
   else
      YLLThrustHackControl:SetThrottle(I, 0)
   end
   -- Blip top & bottom thrusters
   if not PRThrustHackDriveMaintainerFacing then
      I:RequestThrustControl(4)
      I:RequestThrustControl(5)
   else
      PRThrustHackControl:SetThrottle(I, 1)
   end

   -- And set drive fraction accordingly
   for _,Info in pairs(PropulsionInfos) do
      local PitchSign,RollSign = Info.PitchSign,Info.RollSign
      if Info.IsVertical or DesiredHeading or DesiredPosition then
         -- Sum up inputs and constrain
         local Output = YawCV * Info.YawSign + PitchCV * PitchSign + RollCV * RollSign + ForwardCV * Info.ForwardSign + RightCV * Info.RightSign
         Output = math.max(0, math.min(10, Output))
         I:Component_SetFloatLogic(PROPULSION, Info.Index, Output / 10)
      else
         I:Component_SetFloatLogic(PROPULSION, Info.Index, 1)
      end
   end
end

function FiveDoF_Disable(I)
   -- Disable drive maintainers, if any
   YLLThrustHackControl:SetThrottle(I, 0)
   PRThrustHackControl:SetThrottle(I, 0)
end
