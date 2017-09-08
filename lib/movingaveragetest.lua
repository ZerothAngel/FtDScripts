require("movingaverage")

ma = MovingAverage.create(3)
ma:AddSample(1)
ma:AddSample(5)
ma:AddSample(10)

print("Should be 5.3333333...")
print(ma.Average)

ma:AddSample(8)

print("Should be 7.6666666...")
print(ma.Average)

ma:AddSample(9)

print("Should be 9")
print(ma.Average)
