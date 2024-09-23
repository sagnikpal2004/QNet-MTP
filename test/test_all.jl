# using QuantumSavory


# registers = [
#     QuantumSavory.Register(Q),
#     # Segment 1
#     QuantumSavory.Register(Q),
#     QuantumSavory.Register(Q),
#     # Segment 2
#     QuantumSavory.Register(Q),
#     QuantumSavory.Register(Q),
#     # Segment 3
#     QuantumSavory.Register(Q),
#     QuantumSavory.Register(Q),
#     # Segment 4
#     QuantumSavory.Register(Q),
# ]

# net = RegisterNet(registers)

# initialize!(net[1,1])
# initialize!(net[2,1])

# apply!([net[1,1], net[2,1]], CNOT)

# fig = CairoMakie.Figure()
# registernetplot_axis(fig[1,1], net)
# display(fig)

# CairoMakie.save("hi.png", fig)

using QuantumSavory

q = QuantumSavory.Register(5)

for field in fieldnames(typeof(q))
    println("$field: $(getfield(q, field))")
end
