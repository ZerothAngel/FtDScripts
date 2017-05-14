require("neuralnet")

TrainingSets = {
   {
      input = { .1, .1 },
      expected = { .1 },
   },
   {
      input = { .1, .9 },
      expected = { .9 },
   },
   {
      input = { .9, .1 },
      expected = { .9 },
   },
   {
      input = { .9, .9 },
      expected = { .1 },
   },
}

NN = NeuralNet.create(2, 3, 1)
math.randomseed(os.time())
NN:Randomize()

Iterations = 0
repeat
   local MaxRMS = 0
   for _,Train in ipairs(TrainingSets) do
      NN:Run(Train.input)
      local rms = NN:Backprop(Train.expected)
      MaxRMS = math.max(MaxRMS, rms)
   end
   Iterations = Iterations + 1
until MaxRMS <= .1

print(string.format("Iterations = %d", Iterations))

function Test(a, b)
   local result = NN:Run({ a, b })[1]
   print(string.format("f(%f, %f) = %f", a, b, result))
end
