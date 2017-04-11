Title: FtD Script Notes
Date: 2017-04-05 00:00
Category: From the Depths
Tags: fromthedepths

# ZerothAngel's FtD Script Notes #

Ultimately, I write these scripts for myself. Half of my enjoyment in these types of games (From the Depths, Space Engineers) is programming the behaviors and systems.

Also, I don't normally do code requests, but I'm open to interesting ideas, especially ones that I'd eventually use myself. (The dumb-fire rocket controller and smart mines are recent examples.)

Having said that all that, here are some notes on how my scripts are used and their likely limitations.

## Mainframes ##

The Lua interface to mainframes is very barebones and minimal. And like the other block-oriented Lua bindings, there's no method to directly address specific blocks.

**So I build with only one mainframe**.

With multiple mainframes, when one gets destroyed and then rebuilt, it gets put at the end of the mainframe list. Since mainframes can only be addressed by their index into this list, this is a big problem. We have no access to the mainframe names, only to their *world* coordinates (which changes from frame to frame as the vehicle moves/rotates). It's probably possible to map this back to local coordinates, but it may still be iffy.

Additionally, `I.AIMode` (which returns the AI's state &mdash; "off", "on", "combat", etc.) only looks at mainframe 0. Depending on damage, mainframe 0 may not be the one with the required cards.

So when using my script (or any Lua script, really), it's best to use a single mainframe **or** equip each mainframe identically (same cards). Something I'm experimenting with is having a single set of cards shared by multiple mainframes (all transmitting on the same channel).

## Thrusters ##

The Lua binding for thruster control, `I:RequestThrustControl`, runs all thrust requests through some sort of propulsion balancing. So if one facing only has jets on one side of the CoM, they will not fire (because it would induce a rotation).

This isn't ideal and causes problems especially if you don't build symmetrically.

This is why I tend to favor quadcopters and dediblade-based airships.

I do have a workaround in place now which requires a drive maintainer for each set of related axes (altitude/pitch/roll is one, yaw/longitudinal/lateral is another). See the `ThrustHackDriveMaintainerFacing` setting and my [related forum post](http://fromthedepthsgame.com/forum/showthread.php?tid=23335&pid=322187#pid322187).

## Missiles ##

Despite most of my scripts being pre-configured for sea-skimming top-attack, I usually redo them for javelin profile in pretty much all of my ships. The main reason being friendly fire. (So now I just have to worry about the missile closing altitude and my aircraft, which is easier to fix.)

I also always hear talk about monstrous 8- or 10- block long missiles.

**I usually just stick with 6 blocks or less**. So my missiles are just a tad more maneuverable and that's what the phase distances in my scripts are tuned for.

## YawPID ##

The yaw-propulsion AIs (naval-ai, repair-ai, utility-ai) all have a YawPID configuration which determines how strong of a yaw signal to send the game.

**This PID is tuned for a single rudder**.

If your vehicle has more rudders, or significantly stronger yawing capability, you will probably need to tune `Kp` down until it stops oscillating.

You may also be interested in my [yawtest](https://tyrannyofheaven.org/ZerothAngel/FtDScripts/yawtest.lua) script to help in tuning, which, while moving forward at various speeds, rotates the vehicle every 90 degrees every minute or so. It also outputs informative stats like turning radius and turning time.
