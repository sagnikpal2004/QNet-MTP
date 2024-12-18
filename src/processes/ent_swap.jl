include("../noisyops/CircuitZoo.jl")


"""Performs an entanglement swap between two qubits in the Network"""
function ent_swap!(N::Network, remoteL::RegRef, localL::RegRef, localR::RegRef, remoteR::RegRef)
    EntanglementSwap(N.ϵ_g, N.ξ)(localL, remoteL, localR, remoteR)

    N.ent_list[remoteL] = remoteR
    N.ent_list[remoteR] = remoteL
    delete!(N.ent_list, localL)
    delete!(N.ent_list, localR)
end


"""Performs entanglement swapping in a node"""
function ent_swap!(N::Network, node::Node)
    q = length(N.nodes[1].right.traits)

    ent_list_L = [(N.ent_list[node.left[q]], node.left[q]) for q in 1:q if node.left[q] in keys(N.ent_list)]
    ent_list_R = [(node.right[q], N.ent_list[node.right[q]]) for q in 1:q if node.right[q] in keys(N.ent_list)]

    for ((remoteL, localL), (localR, remoteR)) in zip(ent_list_L, ent_list_R)
        QuantumNetwork.ent_swap!(N, remoteL, localL, localR, remoteR)
    end

    len_diff = length(ent_list_L) - length(ent_list_R)
    while len_diff > 0
        (remoteL, localL) = pop!(ent_list_L)
        traceout!(localL); delete!(N.ent_list, localL)
        traceout!(remoteL); delete!(N.ent_list, remoteL)
        len_diff -= 1
    end
    while len_diff < 0
        (localR, remoteR) = pop!(ent_list_R)
        traceout!(localR); delete!(N.ent_list, localR)
        traceout!(remoteR); delete!(N.ent_list, remoteR)
        len_diff += 1
    end

    node.connectedTo_L.connectedTo_R = node.connectedTo_R
    node.connectedTo_R.connectedTo_L = node.connectedTo_L
    node.isActive = false
end
ent_swap!(N::Network, i::Int) = ent_swap!(N, N.nodes[i])


"""Performs entanglement swapping in all Repeaters in the Network"""
function ent_swap!(N::Network)
    n = length(N.nodes)-2

    for i in 1:log(2, n+1)
        for j in 1:n+1
            if j % 2^i == (2^i)/2
                QuantumNetwork.ent_swap!(N, j+1)
            end
        end
        if QuantumNetwork.getFidelity(N) < 0.95
            QuantumNetwork.purify!(N)
        end
    end
end