# To Do #

 * Altitude/depth control could be smoothed out a bit. It's a bit messy adding a downstream process (i.e. an AI module) to control altitude & dodging separately. Note that it's a lot better now, but only allows for 1 high-priority offset (i.e. missile dodge). This is good enough for now.

 * Missile Driver: Make it easier to plug in an interceptor script or module. Currently, interceptor missiles are ignored by MissileDriver, which should allow a well-behaved interceptor script to run in parallel. However, this can probably be improved.

 * Simplificaton of gunship-ai configuration, especially the pitch/hull weapon aiming stuff.

 * Adopt the game's lingo for certain options, e.g. wander distance.

 * naval-ai: Get rid of AirRaidEvasion.

 * Get rid of dediblade "always up" options.

 * sixdof: Consider converting fully to vehicle control outputs. However, current Lua interface
   does not allow RequestControl on strafe or hover axes.
   Unfortunately, Lua cannot write to (non-stim) secondary & tertiary drives either.
   Nor does Lua have access to the misc axes or custom axes.
   So the one way to make this work is via 2 drive maintainers as fake strafe/hover outputs.
   (Also note that drive maintainers cannot be hooked up to dediblades. WTF!)
   This would leave only 1 drive maintainer for any sort of manual control (e.g. altitude).
   Also drive maintainers might be on their way out...
