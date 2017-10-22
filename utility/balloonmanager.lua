--@ commons
-- Balloon manager module
function BalloonManager_Update(I)
   local Altitude = C:Altitude() - (BalloonManagerConfig.GroundRelative and C:Ground() or 0)
   -- Always deploy when below deployment altitude
   if Altitude < BalloonManagerConfig.DeployBelow then
      I:DeployAllBalloons()
   elseif Altitude > BalloonManagerConfig.SeverAbove then
      I:SeverAllBalloons()
   end
end

function BalloonManager_Disable(I)
   I:SeverAllBalloons()
end

function BalloonManager_Control(I)
   if C:IsDocked() then
      BalloonManager_Disable(I)
   else
      BalloonManager_Update(I)
   end
end
