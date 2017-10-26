-- Neural network module
NeuralNet = {}

function NeuralNet.new(NumInput, NumHidden, NumOutput)
   if type(NumHidden) ~= "table" then
      NumHidden = { NumHidden }
   end

   local self = {}

   local Layers = { NeuralNet.CreateLayer(NumInput) }
   local Previous = Layers[1]
   for _,Count in ipairs(NumHidden) do
      local Layer = NeuralNet.CreateLayer(Count, Previous)
      table.insert(Layers, Layer)
      Previous = Layer
   end
   table.insert(Layers, NeuralNet.CreateLayer(NumOutput, Previous))

   self.Layers = Layers
   self.Activation = math.tanh
   self.dActivation = function (_, fx) return 1 - fx*fx end
   self.LearningRate = .1
   self.Momentum = .8

   self.Randomize = NeuralNet.Randomize
   self.Run = NeuralNet.Run
   self.Backprop = NeuralNet.Backprop

   return self
end

function NeuralNet.CreateLayer(NumNodes, Previous)
   local Nodes = {}

   --# Extra node for bias node
   for i = 1,NumNodes+1 do
      local Node = {}
      if Previous and i <= NumNodes then
         local Weights = {}
         for _ = 1,#Previous do -- Include bias node
            table.insert(Weights, {})
         end
         Node.Weights = Weights
      end
      table.insert(Nodes, Node)
   end
   -- Extra node is bias node
   Nodes[#Nodes].a = 1

   return Nodes
end

function NeuralNet:Randomize()
   for i = 2,#self.Layers do -- Skip input layer
      local Layer = self.Layers[i]
      for j = 1,#Layer-1 do -- Skip bias node
         local Node = Layer[j]
         for _,Weight in pairs(Node.Weights) do -- Include bias weight
            Weight.w = 2 * math.random() - 1
            Weight.del_w = 0
         end
      end
   end
end

function NeuralNet.RunLayer(Layer, Previous, Activation)
   for i = 1,#Layer-1 do -- Skip bias node
      local Node = Layer[i]
      -- Sum up inputs
      local input = 0
      for j,Weight in pairs(Node.Weights) do -- Include bias weight
         input = input + Weight.w * Previous[j].a
      end
      Node.input = input
      -- Pass to activation function
      Node.a = Activation(input)
      Node.err = 0
   end
end

function NeuralNet:Run(Inputs)
   -- Set inputs
   local InputLayer = self.Layers[1]
   for i = 1,#InputLayer-1 do -- Skip bias node
      InputLayer[i].a = Inputs[i]
   end

   -- Run forward over hidden + output layers
   local Previous = InputLayer
   for i = 2,#self.Layers do
      local Layer = self.Layers[i]
      NeuralNet.RunLayer(Layer, Previous, self.Activation)
      Previous = Layer
   end

   -- Extract output
   local Output = {}
   local OutputLayer = self.Layers[#self.Layers]
   for i = 1,#OutputLayer-1 do -- Skip bias node
      table.insert(Output, OutputLayer[i].a)
   end

   return Output
end

function NeuralNet:Backprop(Targets)
   local RMSError = 0

   -- Calculate error @ outputs
   local OutputLayer = self.Layers[#self.Layers]
   for i = 1,#OutputLayer-1 do -- Skip bias node
      local Node = OutputLayer[i]
      -- Error/output delta calculation is simple
      Node.err = Targets[i] - Node.a
      Node.del = Node.err * self.dActivation(Node.input, Node.a)
      RMSError = RMSError + Node.err * Node.err
   end

   -- Propagate backwards to hidden layers
   local Next = OutputLayer
   for i = #self.Layers-1,2,-1 do -- Exclude input layer
      local Layer = self.Layers[i]
      -- Relies on hidden err being previously zeroed
      for j = 1,#Next-1 do -- Skip bias node
         local Node = Next[j]
         for k = 1,#Node.Weights-1 do -- Skip bias weight
            local Hidden = Layer[k]
            -- Calculate hidden's share of error
            Hidden.err = Hidden.err + Node.Weights[k].w * Node.del
         end
      end
      -- Now calculate output delta
      for j = 1,#Layer-1 do -- Skip bias node
         local Node = Layer[j]
         Node.del = Node.err * self.dActivation(Node.input, Node.a)
      end
      Next = Layer
   end

   -- Finally, update weights of hidden + output layers
   local Previous = self.Layers[1]
   for i = 2,#self.Layers do
      local Layer = self.Layers[i]
      for j = 1,#Layer-1 do -- Skip bias node
         local Node = Layer[j]
         for k,Weight in pairs(Node.Weights) do -- Include bias weight
            -- Save previous weight delta for momentum
            local del_w = Weight.del_w
            -- Calculate new weight delta
            Weight.del_w = self.LearningRate * Previous[k].a * Node.del
            -- Update weight
            Weight.w = Weight.w + Weight.del_w + self.Momentum * del_w
         end
      end
      Previous = Layer
   end

   return math.sqrt(RMSError / (#OutputLayer-1))
end
