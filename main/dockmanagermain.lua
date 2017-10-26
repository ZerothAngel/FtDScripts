--! dockmanager
--@ commons periodic dockmanager
DockManager = Periodic.new(UpdateRate, DockManager_Update)

function Update(I) -- luacheck: ignore 131
   C = Commons.new(I)
   DockManager:Tick(I)
end
