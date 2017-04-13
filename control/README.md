# Control Modules #

Various modules for moving or rotating the ship along 1 or more degrees of freedom. Modules that
control complementary DoFs can be combined.

## Libraries ##

  * altitudecontrol &mdash; Automatic/manual altitude control for anything above sea level.
  * depthcontrol &mdash; Automatic/manual altitude control for anything below sea level.
  * spinnercontrol &mdash; Generic module for controlling spinners oriented along a given axis.
  
## 2 Degrees of Freedom ##

  * pitchrollstab &mdash; Pitch & roll stabilization by using standard ship pitch & roll controls.
  * yawthrottle &mdash; Uses standard ship controls (e.g. as from a vehicle controller) for yaw and throttle (forward/reverse). Can also use forward/reverse-oriented spinners for propulsion and side-facing spinners for yaw.

## 3 Degrees of Freedom ##

  * aprthreedof &mdash; Altitude/pitch/roll control using jets and/or spinners.
  * yllthreedof &mdash; Yaw/longitudinal/lateral control using jets and/or spinners.
  * subcontrol &mdash; Depth and pitch/roll control using hydrofoils.
  * threedofpump &mdash; Pump control for altitude/pitch/roll.

## 6 Degrees of Freedom ##

  * sixdof &mdash; Altitude/yaw/pitch/roll/longitudinal/lateral control using jets and/or spinners.

## Interface ##

Set* &mdash; Set to given absolute value

Adjust* &mdash; Adjust by given relative value

Reset* &mdash; Hint to release control along this/these degree(s) of freedom

  * SetHeading/AdjustHeading/ResetHeading &mdash; Yaw
  * SetAltitude/AdjustAltitude &mdash; Altitude (Global Y-axis)
  * SetPosition/AdjustPosition/ResetPosition &mdash; Planar position (Global X & Z-axis)
  * SetPitch/SetRoll &mdash; Pitch & roll
  * SetThrottle/AdjustThrottle/ResetThrottle &mdash; Forward/reverse throttle (Longitudinal axis)
  * Control_Reset &mdash; Typically releases control along X & Z plane. Main module's responsibility to actually map this function.
