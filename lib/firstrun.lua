-- FirstRun module
FirstRunList = {}

function FirstRun(I)
   FirstRun = nil

   for _,Function in pairs(FirstRunList) do
      Function(I)
   end
end

function AddFirstRun(Function)
   table.insert(FirstRunList, Function)
end
