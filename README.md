# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts and the libraries/modules used to build them.

## Scripts ##

I'll only list the interesting scripts (the ones not used for research or testing).

### AI Replacements ###

  * [gatherer-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gatherer-ai.lua) &mdash; Gatherer AI (2D only) with terrain/friendly avoidance.
  * [gunship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua) &mdash; Gunship AI, dedicated heliblade spinner for lift, jets for 5-axis control (yaw, pitch, roll, forward/backward, right/left).
  * [gunshipquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunshipquad.lua) &mdash; Gunship AI, dedicated heliblade spinners for lift and pitch/roll control, jets for 3-axis control (yaw, forward/backward, right/left).
  * [naval-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/naval-ai.lua) &mdash; Naval AI with terrain/friendly avoidance and pseudo-random evasive maneuvers. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20953))
  * [repair-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repair-ai.lua) &mdash; Advanced repair AI (2D only) with terrain/friendly avoidance. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20998))

### Altitude/Depth Control (Only) ###

  * [aerostat](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/aerostat.lua) &mdash; Controls helium pumps for lift and pitch/roll stabilization. Meant for use in combination with a 2D AI.
  * [hover](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/hover.lua) &mdash; Dedicated heliblade spinner for lift, jets for 2-axis control (pitch, roll). Meant for use in combination with a 2D AI.
  * [quadcopter](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/quadcopter.lua) &mdash; Dedicated heliblade spinners for lift and pitch/roll control. Meant for use in combination with a 2D AI.
  * [subcontrol](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subcontrol.lua) &mdash; Hydrofoil script with pitch, roll, depth control + manual depth option. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21908))

### Missile Scripts ###

  * [dualprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dualprofile.lua) &mdash; Dual-profile missile script, using a separate unifiedmissile instance for vertically- and horizontally-launched missiles. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))
  * [multiprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/multiprofile.lua) &mdash; Multiple profile missile script, up to one unifiedmissile instance for each weapon slot. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))
  * [unifiedmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/unifiedmissile.lua) &mdash; Highly configurable advanced missile script that supports a variety of attack profiles. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))

### Combo Scripts ###

  * [airship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airship.lua) &mdash; Combo script: naval-ai + quadcopter + dualprofile
  * [gatherer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gatherer.lua) &mdash; Combo script: gatherer-ai + quadcopter
  * [repairheli](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairheli.lua) &mdash; Combo script: repair-ai + hover
  * [repairquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairquad.lua) &mdash; Combo script: repair-ai + quadcopter
  * [repairsub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairsub.lua) &mdash; Combo script: repair-ai + subcontrol
  * [submarine](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/submarine.lua) &mdash; Combo script: naval-ai + subcontrol + dualprofile
  * [warship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/warship.lua) &mdash; Combo script: naval-ai + dualprofile

### Miscellaneous ###

  * [dediblademaintainer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dediblademaintainer.lua) &mdash; Allows linking a drive maintainer to forward/reverse-oriented dediblades for propulsion.
  * [stabilizer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/stabilizer.lua) &mdash; 2-axis control (pitch, roll).

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
