--# commons sign pid clamp
PitchThrottle_PitchPID = PID.new(PitchThrottle.Pitch, -1, 1)

PitchThrottleControl = {}

PitchThrottle_DesiredThrottle = nil
PitchThrottle_CurrentThrottle = 0

function PitchThrottle.SetThrottle(Throttle)
    --# Note: We can't swap the PitchThrottle.*Throttle methods at runtime because
    --# we more or less bind immediately before the first Update.
    if PitchThrottle.DesiredPitch then
        PitchThrottle_DesiredThrottle = Clamp(Throttle, -1, 1)
    else
        -- Just pass through
        PitchThrottleControl.SetThrottle(Throttle)
    end
end

function PitchThrottle.GetThrottle()
    if PitchThrottle.DesiredPitch then
        return PitchThrottle_CurrentThrottle
    else
        -- Just pass through
        return PitchThrottleControl.GetThrottle()
    end
end

function PitchThrottle.ResetThrottle()
    PitchThrottleControl.ResetThrottle()
    PitchThrottle_DesiredThrottle = nil
end

function PitchThrottle.Update(_)
    if PitchThrottle.DesiredPitch then
        if PitchThrottle_DesiredThrottle then
            PitchThrottle_CurrentThrottle = PitchThrottle_DesiredThrottle

            local PitchCV = Clamp(PitchThrottle_PitchPID:Control(PitchThrottle.DesiredPitch - C:Pitch()), -1, 0)
            -- Modulate based on current pitch CV
            local MaxThrottle = 1 + PitchCV
            PitchThrottleControl.SetThrottle(PitchThrottle_CurrentThrottle * MaxThrottle)
        end
    end
    -- If not enabled, do nothing
end
