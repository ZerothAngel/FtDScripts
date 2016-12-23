--! cameratrack
--@ commons periodic cameratrack
CameraTrack = Periodic.create(UpdateRate, CameraTrack_Update)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      C = Commons.create(I)
      CameraTrack:Tick(I)
   end
end
