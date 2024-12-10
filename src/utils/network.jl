import CairoMakie
import QuantumSavory

"""Converts a Network into a QuantumSavory.RegiterNet"""
function toRegisterNet(N::Network)
    registers::Vector{Register} = []

    for node in N.nodes
        if node.isActive
            if !isnothing(node.left)
                push!(registers, node.left)
            end
            if !isnothing(node.right)
                push!(registers, node.right)
            end
        end
    end

    return QuantumSavory.RegisterNet(registers)
end

"""Returns a figure representing the current state of the Network"""
function netplot(N::Network)
    n = length(N.nodes)-2
    q = length(N.nodes[1].right.traits)
    
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1, 1])
    
    coords::Vector{CairoMakie.Point2f} = []
    push!(coords, CairoMakie.Point2f(2, 1))
    for i in 1:n
        if N.nodes[i+1].isActive
            push!(coords, CairoMakie.Point2f(10*i+1, 1))
            push!(coords, CairoMakie.Point2f(10*i+2, 1))
        end
    end
    push!(coords, CairoMakie.Point2f(10*(n+1)+1, 1))
    
    CairoMakie.xlims!(ax, 0, 10*(n+1)+2)
    CairoMakie.ylims!(ax, 0, q+1)
    CairoMakie.hidedecorations!(ax)
    CairoMakie.hidespines!(ax)
    
    net = toRegisterNet(N)
    QuantumSavory.registernetplot!(ax, net, registercoords=coords)

    return fig
end


"""Returns the fidelity of the Network"""
function getFidelity(N::Network)
    length(N.ent_list) == 0 && return 1.0
    return sum(getFidelity(q1) for (q1, q2) in N.ent_list) / length(N.ent_list)
end
function getFidelity(q::QuantumSavory.RegRef)
    state = q.reg.staterefs[q.idx].state[]
    @assert basis(state) == basis2 "State must be in basis2"

    if isa(state, QuantumOptics.Ket)
        return abs2(ϕ⁺' * state)
    end; return real(ϕ⁺' * state * ϕ⁺)
end

"""Gets the communication times between two indexed nodes"""
function getCommTime(N::Network, i::Int, j::Int)
    @assert 1 <= i <= length(N.nodes) "i must be in [1, length(N.nodes)]"
    @assert i <= j <= length(N.nodes) "j must be in [i, length(N.nodes)]"
    
    return sum(N.t_comms[i:j-1])
end
function getCommTime(N::Network, nodeL::Node, nodeR::Node)
    return getCommTime(N, findfirst(N.nodes, nodeL), findfirst(N.nodes, nodeR))
end