--@ commons
if DebugConfig.Enabled then
   function Log(Message, ...)
      local Formatted = string.format(Message, ...)
      if DebugConfig.LogToHud then
         C.I:LogToHud(Formatted)
      else
         C.I:Log(Formatted)
      end
   end
else
   -- Do nothing
   function Log(_) end
end
