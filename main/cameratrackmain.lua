--! cameratrack
--@ cameratrack periodic
CameraTrack = Periodic.create(UpdateRate, CameraTrack_Update)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      CameraTrack:Tick(I)
   end
end
