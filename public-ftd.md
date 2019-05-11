Title: Public FtD Scripts
Date: 2019-05-09 00:00
Category: From the Depths
Tags: fromthedepths

# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts I've written since I started playing (about the middle of 2016).

## Scripts ##

I'll only list the interesting scripts (the ones not used for research or testing).

Also see my [notes]({filename}ftd-notes.md) about assumptions and possible gotchas.

## How to Use ##

When configuring one of my scripts, I recommend doing so in an external text editor. (Unless it's a really small change, don't do it within the game. Also the game only displays the first 500 lines or so which may be a problem for my larger scripts.)

On Windows, use something like [Notepad++](https://notepad-plus-plus.org). Don't use the editors that come with Windows (Notepad, WordPad).

On Macs, "Text Edit" might be good enough (be sure to switch it to plain text), but I recommend something more programming-oriented. There's plenty of choices, maybe start with [TextWrangler](https://www.barebones.com/products/textwrangler/) or [Sublime Text](https://www.sublimetext.com).

Once you've made your changes in an editor, CTRL-A then CTRL-C (or the Mac equivalent) to get the entire script into your clipboard.

Then open the Lua box (make sure it is on the edit tab), and (**very important!**) CTRL-A to fully select the existing script.

Then CTRL-V. Hit "apply changes" and you should be good to go.

### AI Replacements ###

These scripts wholly replace the "combat" and "fleetmove" behavior of the stock AI. (Still, using the stock Naval AI Card with these scripts is recommended, even for aircraft, as it provides a sane "patrol" behavior.)

All the combat-oriented scripts (everything but repair-ai and utility-ai) have the ability to dodge missiles that have been detected.

When using with an altitude control script, try using a combo script that includes the desired AI module (see below). It will have better integration (e.g. missile dodging also modifies altitude) and it will be more efficient in terms of CPU usage.

  * [airplane](https://zerothangel.com/FtDScripts/airplane.lua) &mdash; This is actually just naval-ai below packaged in a combo script meant for anything that flies like an airplane, i.e. responds to yaw/pitch/roll/propulsion controls. Supports banked turns and like naval-ai, supports broadside and attack run behaviors. Similar to the stock Aerial AI, but potentially much smoother since it has a number of built-in PIDs. See [the brief guide]({filename}airplane.md).
  * [cruisemissile](https://zerothangel.com/FtDScripts/cruisemissile.lua) &mdash; Cruise missile/kamikaze AI that supports multiple phases and interaction with ACBs (through complex controller keys). Meant for anything that flies like an airplane, configured similarly to my airplane script. ([Forum post](http://fromthedepthsgame.com/forum/showthread.php?tid=30980) and [Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=1172433813))
  * drop-ai &mdash; Dropship/boarding AI which follows the closest enemy and keeps the ship directly above (or below) it. This comes as a combo script, [a 6DoF jet/spinner version](https://zerothangel.com/FtDScripts/drop.lua). There's currently no standalone version. ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=839137591))
  * gunship-ai &mdash; A standoff AI that attempts to keep at a set distance from the target while continuously facing it. Moves laterally and longitudinally (forward *and* backward) to do so. Comes as a combo script, [a 6DoF jet/spinner version](https://zerothangel.com/FtDScripts/gunship.lua). No standalone version currently available. ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=764285025))
  * [naval-ai](https://zerothangel.com/FtDScripts/naval-ai.lua) &mdash; Naval AI (2D only) with terrain/friendly avoidance and pseudo-random evasive maneuvers. Supports both broadside and attack run behaviors. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20953))
  * [repair-ai](https://zerothangel.com/FtDScripts/repair-ai.lua) &mdash; Advanced repair AI (2D only) with terrain/friendly avoidance. Fixates on the closest friendly and follows it throughout battle. However, it will head out to repair other nearby friendlies as well. ([Forum post](http://www.fromthedepthsgame.com/forum/showthread.php?tid=20998)) ([Demo thrustercraft](https://steamcommunity.com/sharedfiles/filedetails/?id=909820783)) ([Demo submarine](https://steamcommunity.com/sharedfiles/filedetails/?id=793039988)) ([Demo quadcopter](https://steamcommunity.com/sharedfiles/filedetails/?id=764281083))
  * [tank-ai](https://zerothangel.com/FtDScripts/tank-ai.lua) &mdash; Tank AI which is my naval-ai packaged with drive maintainer-based tank steering controls. Requires two drive maintainers, one for the left track, one for the right track. My naval-ai is flexible enough to support tank-like behaviors, so I haven't bothered writing a true tank AI yet. ([Current forum post](http://fromthedepthsgame.com/forum/showthread.php?tid=31002))
  * [utility-ai](https://zerothangel.com/FtDScripts/utility-ai.lua) &mdash; Utility AI (2D only) with terrain/friendly avoidance. Meant for non-combatant ships in adventure mode. Has automatic wreck-collecting & resource gathering functions. ([Demo mobile base](https://steamcommunity.com/sharedfiles/filedetails/?id=766299628)) ([Demo quadcopter](https://steamcommunity.com/sharedfiles/filedetails/?id=770772414))

### Altitude/Depth Control (Only) ###

Note: Nowadays, it is probably better to use the in-game breadboard or PIDs to control altitude/pitch/roll.

These scripts only provide altitude or depth control. They are meant to be used alongside a 2-dimensional AI, like the Naval AI card (or many of my AI scripts above). They also work fine with manual yaw & propulsion. All scripts will also allow manual (analog) control of the altitude/depth using a drive maintainer.

Again, if you're going to use these with my AI scripts, using a combo script (below) provides better integration and is more efficient.

  * [subcontrol](https://zerothangel.com/FtDScripts/subcontrol.lua) &mdash; Hydrofoil script with pitch, roll, depth control + manual depth option. ([Forum post #1](http://www.fromthedepthsgame.com/forum/showthread.php?tid=21908) [Forum post #2](http://www.fromthedepthsgame.com/forum/showthread.php?tid=23335))
  * [hover](https://zerothangel.com/FtDScripts/hover.lua) &mdash; Upward- or downward-facing jets and/or spinners for lift and pitch/roll control.

### Missile Scripts ###

#### generalmissile-based ####

These use the new configuration scheme detailed [in this doc]({filename}generalmissile.md).

  * [generalmissile](https://zerothangel.com/FtDScripts/generalmissile.lua) &mdash; Highly configurable missile script that supports dual-mode operation (AA or profile), an arbitrary number of profile phases, directional approach, and variable thrust control. Only bother with this script if you're interested in only having a single type of missile on your vehicle. Otherwise, use multiprofile below.
  * [multiprofile](https://zerothangel.com/FtDScripts/multiprofile.lua) &mdash; Multiple profile missile script, based on generalmissile. Profiles can be selected by weapon slot, launcher direction (left, right, up, etc.) or launcher orientation (horizontal/vertical). ([Documentation]({filename}multiprofile.md))

#### Miscellaneous ####

  * [smartmine](https://zerothangel.com/FtDScripts/smartmine.lua) &mdash; aka mobilemine. Rocket-propelled magnetic mines that automatically match depth and minimizes magnetic range when friendlies are nearby.

### Turret Scripts ###

I've only recently started dabbling in Lua-aimed cannon turrets. Frankly, I don't see any solid advantages yet (aside from making the LWC/receiver/failsafe combo unnecessary). And you lose quite a bit, like failsafes and the ability to have AI-assisted manual targeting.

But it was an interesting exercise, and it **does** seem to be quite a bit more accurate.

  * [cameratrack](https://zerothangel.com/FtDScripts/cameratrack.lua) &mdash; Controls turrets on a single weapon group and points them at the highest-priority enemy. Meant for cameras (so you can have a non-cheaty pseudo-3rd person view in adventure mode), **does not compute firing solutions for weapons**. Also useful for directing sensor turrets without the need for a missile controller+LWC.
  * [cannoncontrol](https://zerothangel.com/FtDScripts/cannoncontrol.lua) &mdash; Cannon fire control script. Uses the quartic (4th degree) ballistic trajectory formula, so it takes gravity (of course) and relative target velocity into account. Can control one or more weapon groups with a different set of targeting limitations for each.

### Combo Scripts ###

I tend to build small and because of that, I avoid having more than a few Lua boxes. So I assemble and use combo scripts that are made up of many of my own scripts. This saves on Lua boxes and is also more efficient &mdash; stuff like targeting and weapon control only needs to happen once per run.

Note that most combo scripts include my generalmissile-based multiprofile missile script. While more flexible, it's quite a bit harder to configure. Be sure to disable it (by setting `Missile_UpdateRate` to `nil`) if you'd like to use a different missile script (in another Lua box).

  * [airplane](https://zerothangel.com/FtDScripts/airplane.lua) &mdash; Combo script: naval-ai + airplane + multiprofile + shieldmanager
  * [airship](https://zerothangel.com/FtDScripts/airship.lua) &mdash; Combo script: naval-ai + hover + multiprofile + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=764284410))
  * [carrier](https://zerothangel.com/FtDScripts/carrier.lua) &mdash; Combo script: naval-ai + dockmanager + shieldmanager
  * [cruisemissile](https://zerothangel.com/FtDScripts/cruisemissile.lua) &mdash; Combo script: cruisemissile + airplane + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=1172433813))
  * [drop](https://zerothangel.com/FtDScripts/drop.lua) &mdash; Combo script: drop-ai + sixdof + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=839137591))
  * [gunship](https://zerothangel.com/FtDScripts/gunship.lua) &mdash; Combo script: gunship-ai + sixdof + multiprofile + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=764285025))
  * [utility](https://zerothangel.com/FtDScripts/utility.lua) &mdash; Combo script: utility-ai + hover + dockmanager + shieldmanager ([Demo ship #1](https://steamcommunity.com/sharedfiles/filedetails/?id=766299628)) ([Demo ship #2](https://steamcommunity.com/sharedfiles/filedetails/?id=770772414))
  * [utility6dof](https://zerothangel.com/FtDScripts/utility6dof.lua) &mdash; Combo script: utility-ai + sixdof + dockmanager + shieldmanager
  * [utilitysub](https://zerothangel.com/FtDScripts/utilitysub.lua) &mdash; Combo script: utility-ai + subcontrol + dockmanager + shieldmanager
  * [repair](https://zerothangel.com/FtDScripts/repair.lua) &mdash; Combo script: repair-ai + hover + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=764281083))
  * [repair6dof](https://zerothangel.com/FtDScripts/repair6dof.lua) &mdash; Combo script: repair-ai + sixdof + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=909820783))
  * [repairsub](https://zerothangel.com/FtDScripts/repairsub.lua) &mdash; Combo script: repair-ai + subcontrol + shieldmanager ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=793039988))
  * [scout](https://zerothangel.com/FtDScripts/scout.lua) &mdash; Combo script: naval-ai + hover + shieldmanager + cameratrack ([Demo ship](https://steamcommunity.com/sharedfiles/filedetails/?id=764283788))
  * [scout6dof](https://zerothangel.com/FtDScripts/scout6dof.lua) &mdash; Combo script: gunship-ai + sixdof + shieldmanager + cameratrack
  * [minelayer](https://zerothangel.com/FtDScripts/minelayer.lua) &mdash; Combo script: gunship-ai + sixdof + mobilemine + shieldmanager
  * [submarine](https://zerothangel.com/FtDScripts/submarine.lua) &mdash; Combo script: naval-ai + subcontrol + multiprofile + shieldmanager ([Demo sub #1](https://steamcommunity.com/sharedfiles/filedetails/?id=847619413)) ([Demo sub #2](https://steamcommunity.com/sharedfiles/filedetails/?id=900462722))
  * [tank](https://zerothangel.com/FtDScripts/tank.lua) &mdash; Combo script: naval-ai + tanksteer + cannoncontrol + multiprofile + shieldmanager
  * [warship](https://zerothangel.com/FtDScripts/warship.lua) &mdash; Combo script: naval-ai + multiprofile + shieldmanager

### Miscellaneous ###

  * [shieldmanager](https://zerothangel.com/FtDScripts/shieldmanager.lua) &mdash; Only activates shields facing enemies. Saves power.
  * [dockmanager](https://zerothangel.com/FtDScripts/dockmanager.lua) &mdash; Staggered release of tractor beams (front-to-back) after first enemy detection. Delayed recall of fighters after last enemy dies.

### Experimental ###

More or less functional, but still works-in-progress.

  * [rocketcontrol](https://zerothangel.com/FtDScripts/rocketcontrol.lua) &mdash; Turret controller for dumbfire rockets or torpedoes. The missiles must not have any fins or guidance. ([Demo platform](http://www.fromthedepthsgame.com/forum/showthread.php?tid=25545&pid=292608#pid292608))
  * [rocketlerp](https://zerothangel.com/FtDScripts/rocketlerp.lua) &mdash; Adaptive turret controller for dumbfire rockets. Linear interpolation version. ([Demo platform](http://www.fromthedepthsgame.com/forum/showthread.php?tid=25545&pid=328398#pid328398))
  * [rocketnn](https://zerothangel.com/FtDScripts/rocketnn.lua) &mdash; Adaptive turret controller for dumbfire rockets. Neural network version. ([Demo platform](http://www.fromthedepthsgame.com/forum/showthread.php?tid=25545&pid=328398#pid328398))
