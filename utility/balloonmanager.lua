--@ commons
-- Balloon manager module
BalloonManager_Active = false

function BalloonManager_Update(I)
   local Altitude = C:Altitude()
   -- Always deploy when below deployment altitude
   if Altitude < BalloonManagerConfig.DeployBelow then
      I:DeployAllBalloons()
   end
   -- And only sever on transition from <= sever altitude to above
   local SeverAbove = BalloonManagerConfig.SeverAbove
   if Altitude <= SeverAbove then
      BalloonManager_Active = true
   elseif BalloonManager_Active and Altitude > SeverAbove then
      I:SeverAllBalloons()
      BalloonManager_Active = false
   end
end

function BalloonManager_Disable(I)
   if BalloonManager_Active then
      -- Sever once more, just in case
      I:SeverAllBalloons()
      -- And reset state
      BalloonManager_Active = false
   end
end

function BalloonManager_Control(I)
   if C:IsDocked() then
      BalloonManager_Disable(I)
   else
      BalloonManager_Update(I)
   end
end
