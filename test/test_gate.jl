using QuantumSavory
using QuantumSymbolics

q1 = QuantumSavory.Qubit()

# function RxGate(theta::Float64)
#     return [
#         cos(theta/2) -im*sin(theta/2); 
#         -im*sin(theta/2) cos(theta/2)
#     ]
# end

# struct RxGate <: QuantumSymbolics.AbstractSingleQubitGate
#     theta::Float64
# end

π = 3.14159265358979323846
x = π/2
Rx_gate = Rx(x)


apply!([q1], Rx_gate)