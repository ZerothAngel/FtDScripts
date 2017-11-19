-- FirstRun module
FirstRunList = {}

function FirstRun(I)
   -- Swap with a no-op function
   FirstRun = function (_) end

   -- And then call all registered functions
   for _,Function in pairs(FirstRunList) do
      Function(I)
   end
end

function AddFirstRun(Function)
   table.insert(FirstRunList, Function)
end
