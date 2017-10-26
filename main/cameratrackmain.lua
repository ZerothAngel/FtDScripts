--! cameratrack
--@ commons periodic cameratrack
CameraTrack = Periodic.new(UpdateRate, CameraTrack_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      CameraTrack:Tick(I)
   end
end
