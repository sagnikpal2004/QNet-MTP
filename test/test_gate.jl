using QuantumSavory
using QuantumInterface
# using QuantumSymbolics

q1 = QuantumSavory.Qubit()

function RxGate(theta::Float64)
    basis = QuantumInterface.PauliBasis(1)
    return QuantumSavory.Operator(basis, [
        cos(theta/2) -im*sin(theta/2); 
        -im*sin(theta/2) cos(theta/2)
    ])
end

RxPiOver2 = RxGate(3.14159265/2)

apply!([q1], RxPiOver2)