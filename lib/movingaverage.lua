-- Moving average module
--# Naive implementation
--# The algorithms w/o a buffer seemed to be more about expontential
--# decay. I want old values gone exactly after N samples.
MovingAverage = {}

function MovingAverage.new(MaxSamples, Zero)
   local self = {}

   self.MaxSamples = MaxSamples
   self.SampleCount = 0
   self.NextSample = 0 -- This will be 0-indexed for sanity
   self.Samples = {}
   self.Average = Zero or 0

   self.AddSample = MovingAverage.AddSample

   return self
end

function MovingAverage:AddSample(Sample)
   local MaxSamples,SampleCount,NextSample = self.MaxSamples,self.SampleCount,self.NextSample

   --# Following is overloaded, used both as real index (of oldest sample)
   --# and the next 0-index.
   local LastSample = NextSample + 1
   --# Optimizing myself, but eh, dunno how good Lua runtime is...
   local SampleCountP1 = SampleCount + 1
   if SampleCount >= MaxSamples then
      -- Add new sample while removing oldest
      self.Average = self.Average + (Sample - self.Samples[LastSample]) / MaxSamples
   else
      -- Not enough samples yet, do cumulative moving average
      self.Average = (Sample + self.Average * SampleCount) / SampleCountP1
   end

   self.SampleCount = math.min(MaxSamples, SampleCountP1)
   self.Samples[LastSample] = Sample
   self.NextSample = LastSample % MaxSamples
end
