--! subcontrol
--@ commons firstrun periodic
--@ subcontrol depthcontrol
SubControl = Periodic.create(UpdateRate, Depth_Control)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   if FirstRun then FirstRun(I) end
   if not C:IsDocked() then
      SubControl:Tick(I)

      Depth_Apply(I)
      SubControl_Update(I)
   end
end
