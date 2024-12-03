import QuantumSavory
using QuantumOptics
include("../src/noisyops/apply.jl")
include("../src/utils/bellstates.jl")

zero = QuantumOptics.dm(QuantumSavory.Ket(basis1, [0.0+0.0im, 1.0+0.0im]))
one = QuantumOptics.dm(QuantumSavory.Ket(basis1, [1.0+0.0im, 0.0+0.0im]))

reg = QuantumSavory.Register(4)
QuantumSavory.initialize!([reg[1], reg[2]], one ⊗ one)
QuantumSavory.initialize!([reg[3], reg[4]], zero ⊗ zero)

apply!([reg[2], reg[3]], QuantumSavory.CNOT; ϵ_g=0.2)

state = reg.staterefs[1].state[]
println(state)
println("Trace: ", tr(state))