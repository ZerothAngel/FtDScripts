# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts and the libraries/modules used to build them.

## Scripts ##

**If you're just looking for scripts, don't download anything above.** The scripts above are just fragments and need to be properly assembled (see the *Building* section below).

Complete scripts can be downloaded from the links below.

I'll only list the interesting scripts (the ones not used for research or testing).

### AI Replacements ###

These scripts wholly replace the "combat" and "fleetmove" behavior of the stock AI.

  * [drop](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/drop.lua) &mdash; Experimental dropship/boarding AI which follows the closest enemy and keeps the ship directly above (or below) it. This is the full 6DoF thruster version that requires thrusters on all 6 sides. Note that I don't actually use this version since Lua control of thrusters is so tempermental. So it may go away.
  * [dropquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dropquad.lua) &mdash; Experimental dropship/boarding AI which follows the closest enemy and keeps the ship directly above (or below) it. This is the quadcopter version that uses dediblades for altitude/pitch/roll control and jets for yaw/longitudinal/lateral movement.
  * [gunship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua) &mdash; Gunship AI (standoff with pseudo-random dodging), dedicated heliblade spinner for lift, jets for 5-axis control (yaw, pitch, roll, longitudinal, lateral).
  * [gunshipquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunshipquad.lua) &mdash; Gunship AI (standoff with pseudo-random dodging), dedicated heliblade spinners for lift and pitch/roll control, jets for 3-axis control (yaw, longitudinal, lateral).
  * [naval-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/naval-ai.lua) &mdash; Naval AI with terrain/friendly avoidance and pseudo-random evasive maneuvers. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20953))
  * [repair-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repair-ai.lua) &mdash; Advanced repair AI (2D only) with terrain/friendly avoidance. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20998))
  * [utility-ai](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utility-ai.lua) &mdash; Utility AI (2D only) with terrain/friendly avoidance. Meant for non-combatant ships in adventure mode. Has automatic wreck-collecting & resource gathering functions.

### Altitude/Depth Control (Only) ###

These scripts only provide altitude or depth control. They are meant to be used alongside a 2-dimensional AI, like the Naval AI card (or my non-gunship AI scripts above). They also work fine with manual yaw & propulsion. All scripts will also allow manual (analog) control of the altitude/depth using a drive maintainer.

  * [aerostat](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/aerostat.lua) &mdash; Controls helium pumps for lift and pitch/roll stabilization. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [hover](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/hover.lua) &mdash; Dedicated heliblade spinner for lift, jets for 2-axis control (pitch, roll). ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [quadcopter](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/quadcopter.lua) &mdash; Dedicated heliblade spinners for lift and pitch/roll control. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [subcontrol](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subcontrol.lua) &mdash; Hydrofoil script with pitch, roll, depth control + manual depth option. ([Forum post #1](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21908) [Forum post #2](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [subpump](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/subpump.lua) &mdash; Controls air pumps for lift and pitch/roll stabilization. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [thrustercraft](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/thrustercraft.lua) &mdash; Jets for lift and pitch/roll control.

### Missile Scripts ###

Note that the "unifiedmissile" module and all scripts based on it have been
superceded by a newer, more general missile module (uncreatively named
"generalmissile").

I have no plans to release (or rather, make a public post about) the new
generalmissile-based scripts. Its configuration complexity has reached the
point where you probably have to be familiar enough with Lua programming
(or at least, use a Lua-aware editor) to get it right. And if you could write
your own Lua scripts, you probably would not be using one of mine.

#### generalmissile-based ####

These use the new configuration scheme detailed [in this doc](https://github.com/ZerothAngel/FtDScripts/blob/master/missile/generalmissile.md).

  * [dualprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dualprofile.lua) &mdash; Dual-profile missile script, using a separate generalmissile instance for vertically- and horizontally-launched missiles.
  * [generalmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/generalmissile.lua) &mdash; Highly configurable missile script that supports dual-mode operation (AA or profile), an arbitrary number of profile phases, directional approach, and variable thrust control.
  * [multiprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/multiprofile.lua) &mdash; Multiple profile missile script, up to one generalmissile instance for each weapon slot.

#### Legacy ####

These all use generalmissile under the hood, but continue to be configured as they were before. I will most likely not add any new configuration options, but they should continue to work for the foreseeable future.

  * [pnmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/pnmissile.lua) &mdash; Experimental script for pure proportional-navigation guidance.
  * [udualprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/udualprofile.lua) &mdash; Dual-profile missile script, using a separate unifiedmissile instance for vertically- and horizontally-launched missiles. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))
  * [umultiprofile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/umultiprofile.lua) &mdash; Multiple profile missile script, up to one unifiedmissile instance for each weapon slot. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))
  * [unifiedmissile](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/unifiedmissile.lua) &mdash; Highly configurable advanced missile script that supports a variety of attack profiles. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21639))

### Combo Scripts ###

Note that all combo scripts that included dualprofile have been switched to
the generalmissile version of dualprofile. See note above about the missile
scripts.

  * [airship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/airship.lua) &mdash; Combo script: naval-ai + quadcopter + dualprofile + shieldmanager
  * [gunship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunship.lua) &mdash; Combo script: gunship-ai + hover + dualprofile + shieldmanager
  * [gunshipquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/gunshipquad.lua) &mdash; Combo script: gunship-ai + quadcopter + dualprofile + shieldmanager
  * [utility](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utility.lua) &mdash; Combo script: utility-ai + quadcopter
  * [utilitysub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/utilitysub.lua) &mdash; Combo script: utility-ai + subcontrol
  * [repairheli](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairheli.lua) &mdash; Combo script: repair-ai + hover
  * [repairquad](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairquad.lua) &mdash; Combo script: repair-ai + quadcopter
  * [repairsub](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/repairsub.lua) &mdash; Combo script: repair-ai + subcontrol
  * [scout](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/scout.lua) &mdash; Combo script: naval-ai + quadcopter + shieldmanager + cameratrack
  * [submarine](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/submarine.lua) &mdash; Combo script: naval-ai + subcontrol + dualprofile + shieldmanager
  * [warship](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/warship.lua) &mdash; Combo script: naval-ai + dualprofile + shieldmanager

### Miscellaneous ###

  * [cameratrack](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/cameratrack.lua) &mdash; Controls a single (2-axis) turret and points at the highest-priority enemy. Meant only for cameras (so you can have a non-cheaty pseudo-3rd person view in adventure mode), does not compute firing solutions for weapons. Also useful for directing sensor turrets without the need for a missile controller+LWC.
  * [dediblademaintainer](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/dediblademaintainer.lua) &mdash; Allows linking a drive maintainer to forward/reverse-oriented dediblades for propulsion.
  * [interceptmanager](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/interceptmanager.lua) &mdash; Fires a weapon slot (presumably a missile interceptor launcher) associated with one of the 4 directional quadrants whenever hostile missiles are detected. Distinguishes between incoming missiles & torpedoes. Saves ammo.
  * [shieldmanager](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/shieldmanager.lua) &mdash; Only activates shields facing enemies. Saves power.
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
