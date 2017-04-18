# To Do #

 * Altitude/depth control could be smoothed out a bit. It's a bit messy adding a downstream process (i.e. an AI module) to control altitude & dodging separately. Note that it's a lot better now, but only allows for 1 high-priority offset (i.e. missile dodge). This is good enough for now.

 * Missile Driver: Make it easier to plug in an interceptor script or module. Currently, interceptor missiles are ignored by MissileDriver, which should allow a well-behaved interceptor script to run in parallel. However, this can probably be improved.

 * Maybe make utility-ai/repair-ai work with a full 6DoF controller (or controller combo), i.e. uses SetPosition if available.

 * Maybe refactor airplane controller so it can work on top of a another control module (or combo of modules) that provides yaw/pitch/roll/throttle.
