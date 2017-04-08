--@ commons
-- Balloon manager module
BalloonManager_LastAltitude = nil

function BalloonManager_Update(I)
   local Altitude = C:Altitude()
   local DeployBelow,SeverAbove = BalloonManagerConfig.DeployBelow,BalloonManagerConfig.SeverAbove
   if (not BalloonManager_LastAltitude or
          (Altitude < DeployBelow and BalloonManager_LastAltitude >= DeployBelow) or
       (Altitude > SeverAbove and BalloonManager_LastAltitude <= SeverAbove)) then
      -- These two methods don't seem to be documented anywhere,
      -- but they're there and they work.
      if Altitude < DeployBelow then
         I:DeployAllBalloons()
      elseif Altitude > SeverAbove then
         I:SeverAllBalloons()
      end
   end
   BalloonManager_LastAltitude = Altitude
end

function BalloonManager_Disable(I)
   if BalloonManager_LastAltitude then
      -- Sever once more, just in case
      I:SeverAllBalloons()
      -- And reset state
      BalloonManager_LastAltitude = nil
   end
end

function BalloonManager_Control(I)
   if C:IsDocked() then
      BalloonManager_Disable(I)
   else
      BalloonManager_Update(I)
   end
end
