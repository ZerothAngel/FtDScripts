--@ commons propulsionapi pid
-- Pitch/roll stabilizer module
RollPID = PID.create(RollPIDConfig, -1, 1)
PitchPID = PID.create(PitchPIDConfig, -1, 1)

DesiredPitch = 0
DesiredRoll = 0

function SetPitch(Angle) -- luacheck: ignore 131
   DesiredPitch = Angle
end

function SetRoll(Angle) -- luacheck: ignore 131
   DesiredRoll = Angle
end

-- Stabilizes via pitch/roll commands.
-- Should be called every update.
function PRStabilizer_Update(I)
   if ControlRoll or ControlPitch then
      local RollCV = ControlRoll and RollPID:Control(DesiredRoll - C:Roll()) or 0
      local PitchCV = ControlPitch and PitchPID:Control(DesiredPitch - C:Pitch()) or 0

      -- Dead simple, just set the appropriate control.
      -- The only advantage over in-game PIDs is the windup prevention...
      if RollCV > 0 then
         I:RequestControl(Mode, ROLLLEFT, RollCV)
      elseif RollCV < 0 then
         I:RequestControl(Mode, ROLLRIGHT, -RollCV)
      end
      if PitchCV > 0 then
         I:RequestControl(Mode, NOSEUP, PitchCV)
      elseif PitchCV < 0 then
         I:RequestControl(Mode, NOSEDOWN, -PitchCV)
      end
   end
end
