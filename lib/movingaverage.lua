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
   self.Total = Zero or 0

   self.AddSample = MovingAverage.AddSample
   self.GetAverage = MovingAverage.GetAverage

   return self
end

function MovingAverage:AddSample(Sample)
   local MaxSamples,SampleCount,NextSample = self.MaxSamples,self.SampleCount,self.NextSample
   local LastSample = (NextSample + 1) % MaxSamples

   if SampleCount >= MaxSamples then
      -- Remove oldest sample from total
      self.Total = self.Total - self.Samples[1 + LastSample]
   end

   self.SampleCount = math.min(MaxSamples, SampleCount + 1)
   self.Samples[1 + NextSample] = Sample
   self.Total = self.Total + Sample
   self.NextSample = LastSample
end

function MovingAverage:GetAverage()
   local SampleCount = self.SampleCount
   if SampleCount == 0 then
      return self.Total -- Meh...
   else
      return self.Total / SampleCount
   end
end
