using QuantumSavory
include("../utils/bellstates.jl")


"""Returns a noisy state with fidelity F"""
function noisy_initstate(F::Float64)
    @assert 0 <= F <= 1
    return (F * Φ⁺) + ((1-F)/3 * Φ⁻) + ((1-F)/3 * Ψ⁺) + ((1-F)/3 * Ψ⁻)
end


"""Entangles two qubits in the Network"""
function entangle!(N::Network, q1::RegRef, q2::RegRef)
    initState = noisy_initstate(N.F)
    QuantumSavory.initialize!([q1, q2], initState)

    N.ent_list[q1] = q2
    N.ent_list[q2] = q1
end


"""Entangles two nodes in the Network"""
function entangle!(N::Network, nodeL::Node, nodeR::Node)
    q = length(N.nodes[1].right.traits)

    for q in 1:q
        if rand() < N.p_ent
            QuantumNetwork.entangle!(N, nodeL.right[q], nodeR.left[q])
        end
    end

    nodeL.connectedTo_R = nodeR
    nodeR.connectedTo_L = nodeL
end
entangle!(N::Network, i::Int, j::Int) = entangle!(N, N.nodes[i], N.nodes[j])


"""Entangles all qubits with their neighbors in the Network"""
function entangle!(N::Network)
    n = length(N.nodes)-2

    for i in 1:n+1
        QuantumNetwork.entangle!(N, i, i+1)
    end
end