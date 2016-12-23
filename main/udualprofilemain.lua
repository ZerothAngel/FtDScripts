--! udualprofile
--@ commons periodic udualprofile
MissileMain = Periodic.create(UpdateRate, MissileMain_Update)

function Update(I) -- luacheck: ignore 131
   if not I:IsDocked() then
      C = Commons.create(I)
      MissileMain:Tick(I)
   end
end
