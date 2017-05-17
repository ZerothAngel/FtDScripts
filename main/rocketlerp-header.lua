-- CONFIGURATION

-- Activate on these AI modes. Valid keys are "off", "on", "combat",
-- "patrol", and "fleetmove".
ActivateWhen = {
   on = true,
   combat = true,
   patrol = true,
   fleetmove = true,
}

-- How often to run. At 1, it will run every update. At 10,
-- it will run every 10th update. The lower it is, the more
-- responsive it will be, but it will also take more processing time.
Capture_UpdateRate = 20

-- Weapon slot of turrets to aim
RocketWeaponSlot = 1

-- Target limits. This is analogous to LWC settings and should be set
-- accordingly.
RocketLimits = {
   MinRange = 0,
   MaxRange = 9999,
   MinAltitude = -500,
   MaxAltitude = 9999,
   -- Set to a number to constrain aim point to a minimum altitude
   -- e.g. 0 or -1 for near-waterline.
   -- Set to nil to disable this constraint.
   -- This differs from the limits above in that the above limits
   -- determine when to fire. ConstrainWaterline just moves the
   -- aim point up if it is too low.
   ConstrainWaterline = 0,
}

-- Time scale in seconds.
-- Should basically be as long as possible BEFORE the rocket runs out of fuel.
-- (When a missile is out of fuel, it is subject to gravity, which will
-- make prediction inaccurate.)
TimeScale = 10

-- Size of the distance table. Generally should be larger than the number
-- of data points (so none are wasted during interpolation).
-- The # of data points is TrainingSamplesNeeded * TimeScale * 40 /
-- Capture_UpdateRate.
LookupTableSize = 100

-- Number of complete rocket runs (from launch to TimeScale seconds) needed
-- before training is started.
-- At least one rocket must be equipped with a Lua receiver and be launched
-- from a launchpad with attached Lua transceiver.
-- If that rocket happens to hit its target or be destroyed, it will not
-- count. So configure this and TimeScale accordingly.
TrainingSamplesNeeded = 2

-- If a rocket ever dips below this altitude, disqualify it for training
-- usage.
SampleMinAltitude = 0

-- First guess for time-to-target when using the neural net distance
-- predictor. This implementation uses the secant method to solve the resulting
-- quadratic equation. The first guess will generally determine how long it
-- will take to converge (or whether it does at all). I haven't figured out a
-- good rule of thumb yet.
FirstGuess = TimeScale / 2
