--! smartmine
--@ commons periodic mobilemine
MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if not C:IsDocked() then
      MissileMain:Tick(I)
   end
end