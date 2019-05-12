--! simplemissile
--@ commons periodic simplemissile
MissileMain = Periodic.new(UpdateRate, MissileMain_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   if not C:IsDocked() then
      MissileMain:Tick(I)
   end
end
