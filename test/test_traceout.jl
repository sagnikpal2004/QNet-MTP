import QuantumSavory
import QuantumInterface
include("../src/noisyops/traceout.jl")

reg = QuantumSavory.Register(4)
QuantumSavory.initialize!([reg[1], reg[2]], one ⊗ one)
QuantumSavory.initialize!([reg[3], reg[4]], zero ⊗ zero)

QuantumSavory.apply!([reg[2], reg[3]], QuantumSavory.CNOT)

project_traceout!(reg[1], QuantumSymbolics.σˣ; ξ=1.0)