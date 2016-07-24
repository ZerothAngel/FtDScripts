# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts and the libraries/modules used to build them.

## Scripts ##

I'll only list the interesting scripts (the ones not used for research or testing).

  * airship &mdash; Combo script: naval-ai + hover + dualprofile
  * dualprofile &mdash; Dual-profile missile script, using a separate unifiedmissile instance for vertically- and horizontally-launched missiles.
  * gunship &mdash; Gunship AI, dedicated heliblade spinner for lift, jets for 5-axis control (yaw, pitch, roll, forward/backward, right/left).
  * hover &mdash; Dedicated heliblade spinner for lift, jets for 2-axis control (pitch, roll). Meant for use in combination with a 2D AI.
  * naval-ai &mdash; Naval AI with terrain/friendly avoidance and pseudo-random evasive maneuvers.
  * repair-ai &mdash; Advanced repair AI (2D only) with terrain/friendly avoidance.
  * repairheli &mdash; Combo script: repair-ai + hover
  * repairsub &mdash; Combo script: repair-ai + subcontrol
  * stabilizer &mdash; 2-axis control (pitch, roll).
  * subcontrol &mdash; Hydrofoil script with pitch, roll, depth control + manual depth option.
  * submarine &mdash; Combo script: naval-ai + subcontrol + dualprofile
  * unifiedmissile &mdash; Highly configurable advanced missile script that supports a variety of attack profiles.
  * warship &mdash; Combo script: naval-ai + dualprofile

## Building ##

Simply run build.py which is a Python 3 script. Assembled scripts will be written to the *out* directory.

### Build System ###

The build system simply concatenates files ("modules") in a specific way. Modules may have 0 or more dependencies designated by Lua comments that start with "--@" (which must appear before any code at the top of the module). Multiple dependent modules must be separated by whitespace.

Main scripts are designated with Lua comments that start with "--!" followed by the output filename.

So a module *foo* will have the main body in a file named *foo.lua*. It may optionally have "header" and/or "footer" segments (misnomers since they're only headers/footers to the main script's **header**, typically used for configurables). If present, they should be named *foo-header.lua* and *foo-footer.lua*.

Once the build script works out the total order of modules (via the dependency system), they are output like so:

1. Header files, in order
2. Footer files, in reverse order
3. Main body, in reverse order
