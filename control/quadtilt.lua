--@ commons control tiltspinner clamp
QuadTilt_TiltSpinner = TiltSpinner.create(Vector3.right, { Kp = .01, Ti = 10, Td = 0, })

QuadTilt_DesiredHeading = nil
QuadTilt_DesiredThrottle = nil

QuadTiltRestAngles = {}
for _=1,8 do
   table.insert(QuadTiltRestAngles, QuadTiltRestAngle)
end

QuadTiltControl = {}

QuadTilt = {}

function QuadTilt.SetHeading(Heading)
   QuadTiltControl.SetHeading(Heading)
   QuadTilt_DesiredHeading = Heading % 360
end

function QuadTilt.ResetHeading()
   QuadTiltControl.ResetHeading()
   QuadTilt_DesiredHeading = nil
end

function QuadTilt.SetThrottle(Throttle)
   QuadTiltControl.SetThrottle(Throttle)
   QuadTilt_DesiredThrottle = Clamp(Throttle, -1, 1)
end

function QuadTilt.GetThrottle()
   return QuadTiltControl.GetThrottle()
end

function QuadTilt.ResetThrottle()
   QuadTiltControl.ResetThrottle()
   QuadTilt_DesiredThrottle = nil
end

function QuadTilt.Update(I)
   if QuadTilt_DesiredHeading or QuadTilt_DesiredThrottle then
      QuadTilt_TiltSpinner:SetAngles(QuadTiltAngles)
   else
      QuadTilt_TiltSpinner:SetAngles(QuadTiltRestAngles)
   end

   QuadTilt_TiltSpinner:Update(I)
end

function QuadTilt.Disable(I)
   QuadTilt_TiltSpinner:Disable(I)
end
