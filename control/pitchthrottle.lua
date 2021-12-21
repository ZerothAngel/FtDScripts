--# commons sign pid clamp
PitchThrottle_PitchPID = PID.new(PitchThrottle.Pitch, -1, 1)

PitchThrottleControl = {}

PitchThrottle_DesiredThrottle = nil
PitchThrottle_CurrentThrottle = 0

function PitchThrottle.SetThrottle(Throttle)
    PitchThrottle_DesiredThrottle = Clamp(Throttle, -1, 1)
end

function PitchThrottle.GetThrottle()
    return PitchThrottle_CurrentThrottle
end

function PitchThrottle.ResetThrottle()
    PitchThrottle_DesiredThrottle = nil
    PitchThrottleControl.ResetThrottle()
end

function PitchThrottle.Update(I)
    if PitchThrottle_DesiredThrottle then
        PitchThrottle_CurrentThrottle = PitchThrottle_DesiredThrottle

        if PitchThrottle.DesiredPitch then
            local PitchCV = Clamp(PitchThrottle_PitchPID:Control(PitchThrottle.DesiredPitch - C:Pitch()), -1, 0)
            -- Modulate based on current pitch CV
            local MaxThrottle = 1 + PitchCV
            PitchThrottleControl.SetThrottle(PitchThrottle_CurrentThrottle * MaxThrottle)
        else
            -- Just pass it through
            PitchThrottleControl.SetThrottle(PitchThrottle_CurrentThrottle)
        end
    end
end
