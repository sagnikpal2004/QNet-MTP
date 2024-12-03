include("../noisyops/CircuitZoo.jl")

"""Applies DEJMPS protocol on two-qubit pairs"""
function purify!(N::Network, memL::RegRef, memR::RegRef, ancL::RegRef, ancR::RegRef)
    purificationcircuit = Purify2to1(:Z, N.ϵ_g, N.ξ)

    success = purificationcircuit(memL, memR, ancL, ancR)

    delete!(N.ent_list, ancL)
    delete!(N.ent_list, ancR)
    if !success
        delete!(N.ent_list, memL)
        delete!(N.ent_list, memR)
    end
end

"""Performs DEJMPS protocol between two nodes"""
function purify!(N::Network, nodeL::Node, nodeR::Node)
    q = length(N.nodes[1].right.traits)

    ent_list = [(nodeL.right[q], N.ent_list[nodeL.right[q]]) for q in 1:q if nodeL.right[q] in keys(N.ent_list) && N.ent_list[nodeL.right[q]].reg == nodeR.left]

    while length(ent_list) > 1
        (memL, memR) = popfirst!(ent_list)
        (ancL, ancR) = popfirst!(ent_list)
        QuantumNetwork.purify!(N, memL, memR, ancL, ancR)
    end
end
purify!(N::Network, nodeL::Int, nodeR::Int) = purify!(N, N.nodes[nodeL], N.nodes[nodeR])

"""Performs DEJMPS protocol network-wide"""
function purify!(N::Network)
    for node in N.nodes
        if !isnothing(node.connectedTo_R)
            QuantumNetwork.purify!(N, node, node.connectedTo_R)
        end
    end
end