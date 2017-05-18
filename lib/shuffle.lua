-- Shuffle a list in place
function shuffle(list)
   for i = #list,2,-1 do
      -- Pick random element from 1..i-1
      local j = 1+math.floor(math.random()*(i-1))
      -- And swap with list[i]
      list[i],list[j] = list[j],list[i]
   end
end
