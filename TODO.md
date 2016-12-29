# To Do #

 * Don't really need all the separate control modules for jets & dediblades. Can probably reduce it down to a 3DOF and 6DOF module. Each module can have a setting for each DOF that specifies how much of that DOF is dedicated to jets (and the remaining goes to dediblades).

 * Altitude/depth control could be smoothed out a bit. It's a bit messy adding a downstream process (i.e. an AI module) to control altitude & dodging separately.

 * In addition to the above, there is no min/max/terrain checks on the altitude control after it is all summed together. Probably best to eventually:

    1. Set desired altitude (via configuration or manually)
    2. Let the AI do its thing
    3. If overridden by AI, use that. Otherwise add in evasion (if configured)
    4. Apply min/max/terrain constraints
    5. Call SetAltitude with constrained value

 * Consider setting up tertiary drive maintainer (and forcing it to full throttle via script) and using that to drive all jets. Loses ability to manually pilot, but much saner since thrust balancing no longer affects things.

 * Missile Driver: Make it easier to plug in an interceptor script or module.

 * Commons: Support caching GetFriendlyInfo
