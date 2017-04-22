# Control Modules #

Various modules for moving or rotating the ship along 1 or more degrees of freedom. Modules that
control complementary DoFs can be combined.

## Libraries ##

  * altitudecontrol &mdash; Automatic/manual altitude control for anything above sea level.
  * depthcontrol &mdash; Automatic/manual altitude control for anything below sea level.
  * spinnercontrol &mdash; Generic module for controlling spinners oriented along a given axis.
  
## 2 Degrees of Freedom ##

  * pitchrollstab &mdash; Pitch & roll stabilization by using standard ship pitch & roll controls.

## 3 Degrees of Freedom ##

  * subcontrol &mdash; Depth and pitch/roll control using hydrofoils.
  * threedofpump &mdash; Pump control for altitude/pitch/roll.

## 4 Degrees of Freedom ##

  * airplane &mdash; Uses standard ship controls for yaw/pitch/roll/throttle for airplane flight. Technically 3DoF as only altitude, heading, and throttle can be directly modified. Altitude & heading parameters are converted to the necessary yaw/pitch/roll control outputs to achieve them.

## 6 Degrees of Freedom ##

  * sixdof &mdash; Altitude/yaw/pitch/roll/longitudinal/lateral control using jets and/or spinners. Highly configurable, can be set to only provide control along arbitrary axes.

## Interface ##

The global table `V` houses the control functions, e.g. `V.SetThrottle`

Set* &mdash; Set to given absolute value

Adjust* &mdash; Adjust by given relative value

Reset* &mdash; Hint to release control along this/these degree(s) of freedom

  * SetHeading/AdjustHeading/ResetHeading &mdash; Yaw
  * SetAltitude/AdjustAltitude &mdash; Altitude (Global Y-axis)
  * SetPosition/AdjustPosition/ResetPosition &mdash; Planar position (Global X & Z-axis)
  * SetPitch/SetRoll &mdash; Pitch & roll
  * SetThrottle/AdjustThrottle/ResetThrottle &mdash; Forward/reverse throttle (Longitudinal axis)
  * Reset &mdash; Typically releases control along X & Z plane. Main module's responsibility to actually map this function.

## Combinations ##

  * airplane cannot be combined with other DoF modules.
  * sixdof can be combined with any 3DoF module so long as altitude/pitch/roll are not enabled.
