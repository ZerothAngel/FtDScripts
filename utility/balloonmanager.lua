--@ commons
-- Balloon manager module
BalloonManager_Deployed = false

function BalloonManager_Kill() -- luacheck: ignore 131
   return BalloonManager_Deployed and BalloonManagerConfig.KillPropulsion
end

function BalloonManager_Update(I)
   local Altitude = C:Altitude() - (BalloonManagerConfig.GroundRelative and C:Ground() or 0)
   -- Always deploy when below deployment altitude
   if Altitude < BalloonManagerConfig.DeployBelow then
      I:DeployAllBalloons()
      BalloonManager_Deployed = true
   elseif Altitude > BalloonManagerConfig.SeverAbove then
      I:SeverAllBalloons()
      BalloonManager_Deployed = false
   end
end

function BalloonManager_Disable(I)
   I:SeverAllBalloons()
   BalloonManager_Deployed = false
end

function BalloonManager_Control(I)
   if C:IsDocked() then
      BalloonManager_Disable(I)
   else
      BalloonManager_Update(I)
   end
end
