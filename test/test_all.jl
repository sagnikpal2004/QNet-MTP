using QuantumSavory

reg = QuantumSavory.Register(8)

# for i in 1:8
#     QuantumSavory.initialize!(reg[i])
# end

print(isnothing(reg.staterefs[1]))

# for i in 1:8
#     QuantumSavory.apply!([reg[i]], H)
# end
