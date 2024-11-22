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
    
    coords::Vector{Point2f} = []
    push!(coords, Point2f(2, 1))
    for i in 1:n
        if N.nodes[i+1].isActive
            push!(coords, Point2f(10*i+1, 1))
            push!(coords, Point2f(10*i+2, 1))
        end
    end
    push!(coords, Point2f(10*(n+1)+1, 1))
    
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

    if isa(state, QuantumOptics.Ket)
        return abs2(ϕ⁺' * state)
    end; return real(ϕ⁺' * state * ϕ⁺)
end