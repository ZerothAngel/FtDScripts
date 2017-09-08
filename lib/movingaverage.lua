-- Moving average module
--# Naive implementation
--# The algorithms w/o a buffer seemed to be more about expontential
--# decay. I want old values gone exactly after N samples.
MovingAverage = {}

function MovingAverage.create(MaxSamples, Zero)
   local self = {}

   self.MaxSamples = MaxSamples
   self.SampleCount = 0
   self.NextSample = 0 -- This will be 0-indexed for sanity
   self.Samples = {}
   self.Average = Zero or 0

   self.AddSample = MovingAverage.AddSample
   self.GetAverage = MovingAverage.GetAverage

   return self
end

function MovingAverage:AddSample(Sample)
   local MaxSamples,SampleCount,NextSample = self.MaxSamples,self.SampleCount,self.NextSample

   if SampleCount >= MaxSamples then
      -- Add new sample while removing oldest
      self.Average = self.Average + (Sample - self.Samples[1 + NextSample]) / MaxSamples
   else
      -- Not enough samples yet, do cumulative moving average
      self.Average = (Sample + self.Average * SampleCount) / (SampleCount + 1)
   end

   self.SampleCount = math.min(MaxSamples, SampleCount + 1)
   self.Samples[1 + NextSample] = Sample
   self.NextSample = (NextSample + 1) % MaxSamples
end
