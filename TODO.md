# To Do #

 * Don't really need all the separate control modules for jets & dediblades. Can probably reduce it down to a 3DOF and 6DOF module. Each module can have a setting for each DOF that specifies how much of that DOF is dedicated to jets (and the remaining goes to dediblades).

 * Altitude/depth control could be smoothed out a bit. It's a bit messy adding a downstream process (i.e. an AI module) to control altitude & dodging separately. Note that it's a lot better now, but only allows for 1 high-priority offset (i.e. missile dodge). This is good enough for now.

 * Missile Driver: Make it easier to plug in an interceptor script or module. Currently, interceptor missiles are ignored by MissileDriver, which should allow a well-behaved interceptor script to run in parallel. However, this can probably be improved.
