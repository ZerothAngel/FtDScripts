-- Control mode. Set to WATER, LAND, or AIR.
-- Change accordingly for helicopters/thrustercraft
-- Note that altitude must be controlled by some other means
Mode = WATER

-- Default minimum speed is 2 for submarines.
if not VehicleConfig.MinimumSpeed then VehicleConfig.MinimumSpeed = 2 end
