--! dockmanager
--@ commons periodic dockmanager
DockManager = Periodic.create(UpdateRate, DockManager_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.create(I)
   DockManager:Tick(I)
end
