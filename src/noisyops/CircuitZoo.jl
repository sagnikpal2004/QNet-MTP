import QuantumSavory
include("./apply.jl")
include("./traceout.jl")


struct EntanglementSwap <: QuantumSavory.CircuitZoo.AbstractCircuit
    ϵ_g::Float64
    ξ::Float64

    function EntanglementSwap(ϵ_g::Float64, ξ::Float64)
        @assert 0 <= ϵ_g <= 1   "ϵ_g must be in [0, 1]"
        @assert 0 <=  ξ  <= 1   "ξ must be in [0, 1]"

        new(ϵ_g, ξ)
    end
end
function (circuit::EntanglementSwap)(localL, remoteL, localR, remoteR)
    apply!((localL, localR), QuantumSavory.CNOT; ϵ_g=circuit.ϵ_g)
    xmeas = project_traceout!(localL, QuantumSavory.σˣ; ξ=circuit.ξ)
    zmeas = project_traceout!(localR, QuantumSavory.σᶻ; ξ=circuit.ξ)
    if xmeas==2
        QuantumSavory.apply!(remoteL, QuantumSavory.Z)
    end
    if zmeas==2
        QuantumSavory.apply!(remoteR, QuantumSavory.X)
    end
    return xmeas, zmeas
end
inputqubits(::EntanglementSwap) = 4


struct Purify2to1 <: QuantumSavory.CircuitZoo.AbstractCircuit
    leaveout::Symbol
    ϵ_g::Float64
    ξ::Float64

    function Purify2to1(leaveout::Symbol, ϵ_g::Float64, ξ::Float64)
        @assert leaveout ∈ (:X, :Y, :Z) "`leaveout` must be one of `:X`, `:Y`, or `:Z`"
        @assert 0 <= ϵ_g <= 1 "ϵ_g must be in [0, 1]"
        @assert 0 <= ξ <= 1 "ξ must be in [0, 1]"
        
        new(leaveout, ϵ_g, ξ)
    end
end
Purify2to1(ϵ_g::Float64, ξ::Float64) = Purify2to1(:X, ϵ_g, ξ)
function (circuit::Purify2to1)(purifiedL, purifiedR, sacrificedL, sacrificedR)
    gate, basis = if circuit.leaveout==:X
        QuantumSavory.CNOT, QuantumSavory.σˣ
    elseif circuit.leaveout==:Z
        QuantumSavory.XCZ, QuantumSavory.σᶻ
    elseif circuit.leaveout==:Y
        QuantumSavory.ZCY, QuantumSavory.σʸ
    end
    apply!((sacrificedL, purifiedL), gate; ϵ_g=circuit.ϵ_g)
    apply!((sacrificedR, purifiedR), gate; ϵ_g=circuit.ϵ_g)
    measa = project_traceout!(sacrificedL, basis; ξ=circuit.ξ)
    measb = project_traceout!(sacrificedR, basis; ξ=circuit.ξ)
    success = measa == measb
    if !success
        QuantumSavory.traceout!(purifiedL)
        QuantumSavory.traceout!(purifiedR)
    end
    success
end
inputqubits(circuit::Purify2to1) = 4