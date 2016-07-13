-- Simple logging wrapper with formatting support
-- Callers should still check Debugging to avoid evaluating arguments
function Debug(I, Subsystem, Message, ...)
   if not Subsystem or Debugging == Subsystem then
      local Formatted = string.format(Message, ...)
      if DebugToHud then
         I:LogToHud(Formatted)
      else
         I:Log(Formatted)
      end
   end
end
