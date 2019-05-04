-- ROLL TURN CONFIGURATION

-- This is more for "Rule of Cool" for my 2D AIs (naval-ai, repair-ai, etc.)
-- If it has any positive impact on turning, it is probably insignificant
-- (because of the AI's lack of pitch controls).

RollTurn = {
   -- Set to a number to enable banked turns.
   -- If the difference between desired heading and current heading
   -- exceeds this number, the vehicle will attempt to roll.
   AngleBeforeRoll = nil,
   -- Maximum roll angle to perform during banked turn.
   MaxRollAngle = 30,
   -- To have the roll angle scale based on the magnitude of the relative
   -- bearing, set the scaling factor here.
   -- To always use MaxRollAngle, set RollAngleGain to nil.
   RollAngleGain = nil,
}
