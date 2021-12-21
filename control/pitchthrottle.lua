--# commons sign pid clamp
PitchThrottle_PitchPID = PID.new(PitchThrottle.Pitch, -1, 1)

PitchThrottleControl = {}

function PitchThrottle.SetThrottle(Throttle)
    if PitchThrottle.DesiredPitch then
        local PitchCV = Clamp(PitchThrottle_PitchPID:Control(PitchThrottle.DesiredPitch - C:Pitch()), -1, 0)
        local MaxThrottle = 1 + PitchCV
        PitchThrottleControl.SetThrottle(Throttle * MaxThrottle)
    else
        PitchThrottleControl.SetThrottle(Throttle)
    end
end

function PitchThrottle.GetThrottle()
    return PitchThrottleControl.GetThrottle()
end

function PitchThrottle.ResetThrottle()
    PitchThrottleControl.ResetThrottle()
end
