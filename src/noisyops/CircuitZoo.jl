include("./apply.jl")
include("./traceout.jl")

struct EntanglementSwap_withnoise <: QuantumSavory.CircuitZoo.AbstractCircuit
    ϵ_g::Float64
    ξ::Float64

    function EntanglementSwap_withnoise(ϵ_g::Float64, ξ::Float64)
        if ϵ_g < 0 || ϵ_g > 1
            throw(ArgumentError("ϵ_g must be in [0, 1]"))
        end
        if ξ < 0 || ξ > 1
            throw(ArgumentError("ξ must be in [0, 1]"))
        end
        new(ϵ_g, ξ)
    end
end
function (circuit::EntanglementSwap_withnoise)(localL, remoteL, localR, remoteR)
    apply_withnoise!((localL, remoteL), QuantumSavory.CNOT; ϵ_g=circuit.ϵ_g)
    xmeas = project_traceout_withnoise!(localL, σˣ; ξ=circuit.ξ)
    zmeas = project_traceout_withnoise!(localR, σᶻ; ξ=circuit.ξ)
    if xmeas==2
        apply_withnoise!(remoteL, Z; ϵ_g=circuit.ϵ_g)
    end
    if zmeas==2
        apply_withnoise!(remoteR, X; ϵ_g=circuit.ϵ_g)
    end
    xmeas, zmeas
end
inputqubits(::EntanglementSwap_withnoise) = 4


struct Purify2to1_withnoise <: QuantumSavory.CircuitZoo.AbstractCircuit
    leaveout::Symbol
    ϵ_g::Float64
    ξ::Float64

    function Purify2to1_withnoise(leaveout::Symbol, ϵ_g::Float64, ξ::Float64)
        if leaveout ∉ (:X, :Y, :Z)
            throw(ArgumentError(lazy"""
            `Purify2to1` can represent one of three purification circuits (see its docstring),
            parameterized by the argument `leaveout` which has to be one of `:X`, `:Y`, or `:Z`.
            You have instead chosen `$(repr(leaveout))` which is not a valid option.
            Investigate where you are creating a purification circuit of type `Purify2to1`
            and ensure you are passing a valid argument.
            """))
        elseif ϵ_g < 0 || ϵ_g > 1
            throw(ArgumentError("ϵ_g must be in [0, 1]"))
        elseif ξ < 0 || ξ > 1
            throw(ArgumentError("ξ must be in [0, 1]"))
        else
            new(leaveout, ϵ_g)
        end
    end
end
Purify2to1_withnoise(ϵ_g::Float64, ξ::Float64) = Purify2to1_withnoise(:X, ϵ_g, ξ)
function (circuit::Purify2to1_withnoise)(purifiedL, purifiedR, sacrificedL, sacrificedR)
    gate, basis = if circuit.leaveout==:X
        CNOT, σˣ
    elseif circuit.leaveout==:Z
        XCZ, σᶻ
    elseif circuit.leaveout==:Y
        ZCY, σʸ
    end
    apply_withnoise!((sacrificedL, purifiedL), gate; ϵ_g=circuit.ϵ_g)
    apply_withnoise!((sacrificedR, purifiedR), gate; ϵ_g=circuit.ϵ_g)
    measa = project_traceout_withnoise!(sacrificedL, basis; ξ=circuit.ξ)
    measb = project_traceout_withnoise!(sacrificedR, basis; ξ=circuit.ξ)
    success = measa == measb
    if !success
        traceout!(purifiedL)
        traceout!(purifiedR)
    end
    success
end
inputqubits(circuit::Purify2to1_withnoise) = 4