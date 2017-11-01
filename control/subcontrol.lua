--@ commons componenttypes pid sign clamp
-- Hydrofoil submarine control module
SubControl_RollPID = PID.new(SubControlPIDConfig.Roll, -1, 1)
SubControl_PitchPID = PID.new(SubControlPIDConfig.Pitch, -1, 1)
SubControl_DepthPID = PID.new(SubControlPIDConfig.Depth, -1, 1)

SubControl_DesiredAltitude = 0
SubControl_DesiredPitch = 0
SubControl_DesiredRoll = 0

SubControl_LastHydrofoilCount = 0
SubControl_HydrofoilInfos = {}

SubControl_UsesHydrofoils = HydrofoilControl.Depth > 0 or HydrofoilControl.Pitch > 0 or HydrofoilControl.Roll > 0
SubControl_ControlAltitude = HydrofoilControl.Depth > 0
SubControl_ControlPitch = HydrofoilControl.Pitch > 0
SubControl_ControlRoll = HydrofoilControl.Roll > 0

SubControl = {}

function SubControl.SetAltitude(Alt)
   SubControl_DesiredAltitude = Alt
end

function SubControl.SetPitch(Angle)
   SubControl_DesiredPitch = Angle
end

function SubControl.SetRoll(Angle)
   SubControl_DesiredRoll = Angle
end

SubControl_Eps = .001

function SubControl_GetHydrofoilSign(BlockInfo)
   -- Check if hydrofoil's forward vector lies on Z-axis and up vector lies on Y-axis.
   local DotZ = BlockInfo.LocalForwards.z
   local DotY = (BlockInfo.LocalRotation * Vector3.up).y
   local ForwardSign = Sign(DotZ, 0, SubControl_Eps)
   local UpSign = Sign(DotY, 0, SubControl_Eps)
   if ForwardSign ~= 0 and UpSign ~= 0 then
      -- Facing forwards or backwards on XZ plane, return appropriate sign
      return ForwardSign * UpSign
   else
      -- Some other orientation
      return 0
   end
end

function SubControl_ClassifyHydrofoils(I)
   local HydrofoilCount = I:Component_GetCount(HYDROFOIL)
   if HydrofoilCount ~= SubControl_LastHydrofoilCount then
      -- Something got damaged or repaired, clear the cache
      SubControl_HydrofoilInfos = {}
      SubControl_LastHydrofoilCount = HydrofoilCount

      -- Keep track of max negative and positive offsets
      -- Note: The numbers stored are always non-negative.
      -- Sign of offset is tracked using the table index (-1 or 1)
      local XMax = {}
      XMax[-1] = 0
      XMax[0] = 0
      XMax[1] = 0

      local ZMax = {}
      ZMax[-1] = 0
      ZMax[0] = 0
      ZMax[1] = 0

      local DepthFraction,PitchFraction,RollFraction = HydrofoilControl.Depth,HydrofoilControl.Pitch,HydrofoilControl.Roll

      -- And repopulate it
      for i = 0,HydrofoilCount-1 do
         local BlockInfo = I:Component_GetBlockInfo(HYDROFOIL, i)
         -- Determine sign and location of hydrofoil
         local LocalSign = SubControl_GetHydrofoilSign(BlockInfo)
         if LocalSign ~= 0 then
            -- Only care about hydrofoils oriented forwards/backwards on XZ
            -- plane
            local CoMOffset = BlockInfo.LocalPositionRelativeToCom
            local CoMOffsetX = CoMOffset.x
            local CoMOffsetZ = CoMOffset.z
            local RollScale = Sign(CoMOffsetX)
            local PitchScale = Sign(CoMOffsetZ)
            local Info = {
               Index = i,
               LocalSign = LocalSign,
               DepthScale = DepthFraction,
               -- Default scale is 1, -1, or 0 depending on sign of offset
               RollScale = RollScale,
               PitchScale = PitchScale,
               CoMOffsetX = CoMOffsetX,
               CoMOffsetZ = CoMOffsetZ,
            }
            table.insert(SubControl_HydrofoilInfos, Info)

            -- Also keep track of furthest hydrofoil on each axis
            CoMOffsetX = math.abs(CoMOffsetX)
            XMax[RollScale] = math.max(XMax[RollScale], CoMOffsetX)

            CoMOffsetZ = math.abs(CoMOffsetZ)
            ZMax[PitchScale] = math.max(ZMax[PitchScale], CoMOffsetZ)
         end
      end

      -- Now go back and pre-calculate scale
      for _,Info in pairs(SubControl_HydrofoilInfos) do
         if ScaleByCoMOffset then
            local CoMOffsetX = Info.CoMOffsetX
            if CoMOffsetX ~= 0 then
               Info.RollScale = XMax[Info.RollScale] / CoMOffsetX
            end

            local CoMOffsetZ = Info.CoMOffsetZ
            if CoMOffsetZ ~= 0 then
               Info.PitchScale = ZMax[Info.PitchScale] / CoMOffsetZ
            end
         end
         Info.RollScale = RollFraction * Info.RollScale
         Info.PitchScale = PitchFraction * Info.PitchScale
      end
   end
end

function SubControl.Update(I)
   local RollCV = SubControl_ControlRoll and SubControl_RollPID:Control(SubControl_DesiredRoll - C:Roll()) or 0
   local PitchCV = SubControl_ControlPitch and SubControl_PitchPID:Control(SubControl_DesiredPitch - C:Pitch()) or 0
   local DepthCV = SubControl_ControlAltitude and SubControl_DepthPID:Control((SubControl_DesiredAltitude - C:Altitude()) * C:UpVector().y) or 0

   if SubControl_UsesHydrofoils then
      SubControl_ClassifyHydrofoils(I)

      -- In case vehicle is going in reverse...
      local VehicleSign = Sign(C:ForwardSpeed(), 1)

      for _,Info in pairs(SubControl_HydrofoilInfos) do
         -- Sum up inputs and constrain
         local Output = Clamp((RollCV * Info.RollScale + PitchCV * Info.PitchScale + Info.DepthScale * DepthCV) * 45, -45, 45)

         I:Component_SetFloatLogic(HYDROFOIL, Info.Index, VehicleSign * Info.LocalSign * Output)
      end
   end
end

function SubControl.Disable(_)
end
