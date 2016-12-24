--! cameratrack
--@ commons periodic cameratrack
CameraTrack = Periodic.create(UpdateRate, CameraTrack_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() then
      CameraTrack:Tick(I)
   end
end
